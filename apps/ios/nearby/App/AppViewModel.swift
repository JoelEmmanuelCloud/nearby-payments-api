import Auth
import AuthenticationServices
import Combine
import Foundation
import Gateway
import HSM
import Identity
import LeanSui
import LeanSuiApi
import LocalAuthentication
import Storage
import UI

/// Central coordinator for the iOS application state, routing, and user session lifecycles.
///
/// `AppViewModel` manages navigation routes, coordinates the initialization of core services
/// (such as the API gateway, session manager, and hardware security module), and monitors
/// user authentication status. It runs entirely on the main actor to guarantee UI thread safety.
@MainActor
final class AppViewModel: ObservableObject {
  /// The active navigation route in the application UI.
  @Published var route: AppRoute

  /// The display name of the currently authenticated user.
  @Published private(set) var userName: String

  /// The current user's id (for keying the app-side profile cache), or "" if no session.
  var currentUserId: String {
    (try? sessionManager.getCurrentSession()?.userId) ?? ""
  }

  /// The current zkLogin Sui address (for the on-chain balance query), or nil if no session.
  var currentSuiAddress: String? {
    (try? sessionManager.getCurrentSession())??.suiAddress
  }

  /// An optional status or error message shown at the root layout level.
  @Published var statusMessage: String?

  /// Local storage provider managing app-level flags (e.g. onboarding completeness).
  let store: AppSessionStore

  /// App-wide transient-message bus, rendered by `ToastHost` at the root.
  let toastController = ToastController()

  /// The Secure Enclave Hardware Security Module used for device signing key generation.
  let hsm: SecureEnclaveHSM

  /// The network client gateway coordinating API requests.
  let gateway: APIGateway

  /// Core session manager coordinating token validation, storage, and persistence.
  let sessionManager: SessionManager

  /// Platform coordinator orchestrating native OAuth (Google and Apple) authentication.
  let authManager: AppleAuthManager

  /// Orchestrator for profile, avatar caching, wallet binding, and SuiNS resolution.
  let identityManager: IdentityManager

  /// Service managing temporary cryptographic state and nonce values for zkLogin.
  let zkLoginService: ZkLoginService

  /// Notification token for observing external Apple ID credential revocation.
  private var revocationObserver: NSObjectProtocol?

  /// Convenience initializer configuring the model with a standard user defaults store.
  convenience init() {
    self.init(store: AppSessionStore(defaults: .standard))
  }

  /// Designated initializer setting up key dependencies, restoring stored sessions,
  /// and starting credential revocation observers.
  ///
  /// - Parameter store: Persistent store provider.
  init(store: AppSessionStore) {
    let hsm = SecureEnclaveHSM()
    self.hsm = hsm
    self.store = store

    let gateway = try! APIGateway(
      baseURLString: AppConstants.baseURLString,
      apiVersion: AppConstants.apiVersion
    )
    self.gateway = gateway

    let sessionManager = SessionManager(
      storage: KeychainProvider(),
      hsm: hsm,
      gateway: gateway
    )
    self.sessionManager = sessionManager
    self.zkLoginService = ZkLoginService(hsm: hsm, sessionManager: sessionManager)

    let bundleId = Bundle.main.bundleIdentifier ?? "com.variance.nearby"
    let authManager = AppleAuthManager(
      gateway: gateway,
      sessionManager: sessionManager,
      bundleId: bundleId
    )
    self.authManager = authManager

    let identityManager = IdentityManager(
      gateway: gateway,
      nsResolver: GraphQLSuiProvider(network: SuiNetwork(kind: AppConstants.suiNetwork)),
      sessionManager: sessionManager
    )
    self.identityManager = identityManager

    self.userName = store.userName()

    if !store.didCompleteOnboarding() {
      route = .onboarding
    } else {
      route = .loading
      routeAfterDeviceSecurityCheck()
    }

    observeProviderRevocation()
  }

  deinit {
    if let revocationObserver {
      NotificationCenter.default.removeObserver(revocationObserver)
    }
  }

  /// Concludes onboarding steps, persists the completion flag, and transitions the app route.
  func finishOnboarding() {
    store.completeOnboarding()
    routeAfterDeviceSecurityCheck()
  }

  /// Re-evaluates biometric permissions when the app moves back to the foreground while on the device security screen.
  func refreshDeviceSecurityGate() {
    guard route == .deviceSecurity else { return }
    routeAfterDeviceSecurityCheck()
  }

  /// Handles sign-in events by saving the username and navigating to the home route or profile setup.
  ///
  /// - Parameter userName: The authenticated user's display name.
  func handleSignInSuccess(userName: String) {
    self.userName = userName
    store.saveUserName(userName)

    // Single writer of Sui properties: derive + persist the (stable) address synchronously now,
    // so it's available to Home (balance) and the signer before we route.
    try? zkLoginService.commitSessionIdentity()

    // Everyone lands on Home after sign-in; claiming a SuiNS name is an optional visit to the
    // profile page from there (no first-run setup ceremony).
    route = .home

    // Background: record the address with the backend (idempotent) then warm up the signer.
    // A forced logout from token refresh routes to login instead of being swallowed.
    Task {
      do {
        try await identityManager.rebind()
        try await zkLoginService.warmUpSigner()
      } catch {
        // Transient / non-session failure → best-effort, no-op (signer simply not cached yet).
      }
    }
  }

  /// Performs a sign-out by revoking backend session tokens, clearing local data, and resetting navigation routes.
  func signOut() {
    statusMessage = "Signing out"

    Task {
      do {
        try await authManager.signOut()
      } catch {
        statusMessage = error.localizedDescription
      }

      clearLocalState()
      routeAfterDeviceSecurityCheck()
    }
  }

  /// Validates the stored authentication state and routes the user to either Home or Login.
  private func checkStoredSession() {
    // "Not logged in" and "session wiped during rebind" converge on the single `clearLocalState`.
    guard (try? authManager.sessionManager.isLoggedIn()) == true else {
      clearLocalState()
      route = .login
      return
    }

    route = .home

    // Best-effort idempotent rebind + warm-up.
    Task {
      do {
        try await identityManager.rebind()
        try await zkLoginService.warmUpSigner()
      } catch let error as SessionError where error == .sessionExpired {
        clearLocalState()
        route = .login
      } catch {
      }
    }
  }

  /// Clears local session state and routes to login. Called when a background maintenance task
  /// (rebind/warm-up) hits a forced session invalidation (`SessionError`) from token refresh.
  private func clearLocalState() {
    store.clearUserName()
    userName = store.userName()
    zkLoginService.clearPending()
    statusMessage = nil
  }

  /// Verifies that system-level device protection is enabled before checking authentication state.
  private func routeAfterDeviceSecurityCheck() {
    if canUseDeviceOwnerAuthentication() {
      route = .loading
      checkStoredSession()
    } else {
      route = .deviceSecurity
    }
  }

  /// Evaluates local authentication policies to verify if a device passcode or biometrics are configured.
  private func canUseDeviceOwnerAuthentication() -> Bool {
    let context = LAContext()
    var error: NSError?
    return context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
  }

  /// Attaches notifications for when the user revokes Apple sign-in privileges from their device Settings.
  private func observeProviderRevocation() {
    revocationObserver = authManager.observeAppleCredentialRevocation { [weak self] in
      Task { @MainActor [weak self] in
        guard let self else { return }
        self.store.clearUserName()
        self.userName = self.store.userName()
        self.route = .login
      }
    }
  }
}
