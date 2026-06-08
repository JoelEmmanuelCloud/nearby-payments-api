import Auth
import AuthenticationServices
import Combine
import Foundation
import Gateway
import HSM
import LeanSui
import LeanSuiApi
import LocalAuthentication
import Storage

/// Central coordinator for the iOS application state, routing, and user session lifecycles.
///
/// `AppViewModel` manages navigation routes, coordinates the initialization of core services
/// (such as the API gateway, session manager, and hardware security module), and monitors
/// user authentication status. It runs entirely on the main actor to guarantee UI thread safety.
@MainActor
final class AppViewModel: ObservableObject {
  /// The active navigation route in the application UI.
  @Published private(set) var route: AppRoute

  /// The display name of the currently authenticated user.
  @Published private(set) var userName: String

  /// An optional status or error message shown at the root layout level.
  @Published var statusMessage: String?

  /// Local storage provider managing app-level flags (e.g. onboarding completeness).
  let store: AppSessionStore

  /// The Secure Enclave Hardware Security Module used for device signing key generation.
  let hsm: SecureEnclaveHSM

  /// The network client gateway coordinating API requests.
  let gateway: APIGateway

  /// Core session manager coordinating token validation, storage, and persistence.
  let sessionManager: SessionManager

  /// Platform coordinator orchestrating native OAuth (Google and Apple) authentication.
  let authManager: AppleAuthManager

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

  /// Handles sign-in events by saving the username and navigating to the home route.
  ///
  /// - Parameter userName: The authenticated user's display name.
  func handleSignInSuccess(userName: String) {
    self.userName = userName
    store.saveUserName(userName)
    route = .home

    // Warm up the zkLogin signer in the background so the multi-second proof is ready
    // before the user attempts to sign. Fire-and-forget; failures are non-fatal here.
    Task { try? await zkLoginService.warmUpSigner() }
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

      store.clearUserName()
      userName = store.userName()
      zkLoginService.clearPending()
      statusMessage = nil
      routeAfterDeviceSecurityCheck()
    }
  }

  /// Validates the stored authentication state and routes the user to either Home or Login.
  private func checkStoredSession() {
    do {
      if try authManager.sessionManager.isLoggedIn() {
        route = .home
      } else {
        store.clearUserName()
        userName = store.userName()
        route = .login
      }
    } catch {
      store.clearUserName()
      userName = store.userName()
      route = .login
    }
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
