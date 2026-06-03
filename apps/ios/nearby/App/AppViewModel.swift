import Auth
import AuthenticationServices
import Combine
import Foundation
import UIKit

@MainActor
final class AppViewModel: ObservableObject {
  @Published private(set) var route: AppRoute
  @Published private(set) var onboardingStep = 0
  @Published private(set) var isSigningIn = false
  @Published private(set) var statusMessage: String?
  @Published private(set) var userName: String

  let onboardingPages: [OnboardingPage] = [
    OnboardingPage(
      title: "Keep nearby access simple",
      message: "Use one account flow for wallets, device trust, and session recovery."
    ),
    OnboardingPage(
      title: "Sign in with device protection",
      message: "Nearby prepares secure storage and hardware-backed checks before sensitive actions."
    ),
    OnboardingPage(
      title: "Continue across platforms",
      message:
        "The same account foundation will power iOS and Android without changing your workflow."
    ),
  ]

  private let store: AppSessionStore
  private let authManager: AppleAuthManager?
  private let sessionManager: SessionManager?
  private var appleSignInNonce: String?

  convenience init() {
    self.init(store: AppSessionStore(defaults: .standard))
  }

  init(store: AppSessionStore) {
    self.store = store
    let authManager = Self.makeAuthManager()
    self.authManager = authManager
    self.sessionManager = authManager?.sessionManager
    self.userName = store.userName()

    if !store.didCompleteOnboarding() {
      route = .onboarding
    } else {
      route = .loading
      checkStoredSession()
    }
  }

  var canGoBackInOnboarding: Bool {
    onboardingStep > 0
  }

  var isLastOnboardingStep: Bool {
    onboardingStep == onboardingPages.count - 1
  }

  func previousOnboardingStep() {
    guard onboardingStep > 0 else { return }
    onboardingStep -= 1
  }

  func nextOnboardingStep() {
    if isLastOnboardingStep {
      finishOnboarding()
    } else {
      onboardingStep += 1
    }
  }

  func finishOnboarding() {
    store.completeOnboarding()
    checkStoredSession()
  }

  func prepareAppleSignInRequest(_ request: ASAuthorizationAppleIDRequest) {
    let nonce = UUID().uuidString
    appleSignInNonce = nonce
    authManager?.prepareAppleRequest(request, nonce: nonce)
  }

  func completeAppleSignIn(_ result: Result<ASAuthorization, Error>) {
    guard let authManager else {
      statusMessage = "Apple sign in is not configured"
      return
    }

    guard let nonce = appleSignInNonce else {
      statusMessage = "Apple sign in could not start"
      return
    }

    isSigningIn = true
    statusMessage = "Completing Apple sign in"

    Task {
      do {
        try await authManager.signInWithApple(result, nonce: nonce)
        userName = "Apple account"
        store.saveUserName(userName)
        statusMessage = nil
        route = .home
      } catch {
        statusMessage = error.localizedDescription
      }

      appleSignInNonce = nil
      isSigningIn = false
    }
  }

  func signInWithGoogle() {
    guard let authManager else {
      statusMessage = "Google sign in is not configured"
      return
    }

    guard let presentationAnchor = Self.presentationAnchor() else {
      statusMessage = "Google sign in could not start"
      return
    }

    isSigningIn = true
    statusMessage = "Completing Google sign in"

    Task {
      do {
        try await authManager.signInWithGoogle(
          nonce: UUID().uuidString,
          presentationAnchor: presentationAnchor
        )
        userName = "Google account"
        store.saveUserName(userName)
        statusMessage = nil
        route = .home
      } catch {
        statusMessage = error.localizedDescription
      }

      isSigningIn = false
    }
  }

  func signOut() {
    guard let authManager else {
      store.clearUserName()
      userName = store.userName()
      statusMessage = nil
      route = .login
      return
    }

    isSigningIn = true
    statusMessage = "Signing out"

    Task {
      do {
        try await authManager.signOut()
      } catch {
        statusMessage = error.localizedDescription
      }

      store.clearUserName()
      userName = store.userName()
      isSigningIn = false
      route = .login
    }
  }

  private func checkStoredSession() {
    guard let sessionManager else {
      route = .login
      return
    }

    route = .loading

    Task {
      do {
        route = try sessionManager.isLoggedIn() ? .home : .login
      } catch {
        statusMessage = error.localizedDescription
        route = .login
      }
    }
  }

  private static func makeAuthManager() -> AppleAuthManager? {
    let bundleId = Bundle.main.bundleIdentifier ?? "com.variance.nearby"

    return try? AppleAuthManager(
      baseURLString: AppConstants.baseURLString,
      apiVersion: AppConstants.apiVersion,
      bundleId: bundleId
    )
  }

  private static func presentationAnchor() -> UIWindow? {
    UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap(\.windows)
      .first { $0.isKeyWindow }
  }
}
