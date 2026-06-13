import AuthenticationServices
import UIKit

/// Presents a programmatic Sign in with Apple and bridges its delegate callbacks to async/await.
///
/// The login screen uses SwiftUI's `SignInWithAppleButton`, but the just-in-time re-authentication
/// path (refreshing an expired zkLogin proof mid-action) has no such button — it drives the
/// authorization controller directly and awaits the result.
@MainActor
final class AppleSignInPresenter: NSObject {
  private var continuation: CheckedContinuation<ASAuthorization, Error>?
  // Set in `present` before `performRequests`, so it is always populated by the time the controller
  // asks for the presentation anchor.
  private var anchor: ASPresentationAnchor!

  /// Presents the Apple authorization sheet for `request` over `anchor` and resumes with its result.
  /// The presenter must outlive the call (it is the controller's delegate); awaiting `present` keeps
  /// it alive.
  func present(request: ASAuthorizationAppleIDRequest, anchor: ASPresentationAnchor) async throws
    -> ASAuthorization
  {
    self.anchor = anchor
    return try await withCheckedThrowingContinuation { continuation in
      self.continuation = continuation
      let controller = ASAuthorizationController(authorizationRequests: [request])
      controller.delegate = self
      controller.presentationContextProvider = self
      controller.performRequests()
    }
  }
}

extension AppleSignInPresenter: ASAuthorizationControllerDelegate {
  func authorizationController(
    controller: ASAuthorizationController,
    didCompleteWithAuthorization authorization: ASAuthorization
  ) {
    continuation?.resume(returning: authorization)
    continuation = nil
  }

  func authorizationController(
    controller: ASAuthorizationController,
    didCompleteWithError error: Error
  ) {
    continuation?.resume(throwing: error)
    continuation = nil
  }
}

extension AppleSignInPresenter: ASAuthorizationControllerPresentationContextProviding {
  func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    anchor
  }
}
