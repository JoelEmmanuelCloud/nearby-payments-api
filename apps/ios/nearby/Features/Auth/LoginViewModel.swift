import Auth
import AuthenticationServices
import Combine
import Foundation
import HSM
import UIKit

/// UI state controller coordinating Google and Apple OAuth processes on iOS.
///
/// `LoginViewModel` prepares secure ephemeral keys and nonces for zkLogin, configures OAuth requests,
/// maps OS callbacks to authentication services, and reports active sign-in status messages to the view.
@MainActor
final class LoginViewModel: ObservableObject {
  private let authManager: AppleAuthManager
  private let zkLoginService: ZkLoginService

  /// Indicates whether an active network sign-in operation is currently in progress.
  @Published private(set) var isSigningIn = false

  /// An optional status, progress, or validation error message displayed in the UI.
  @Published private(set) var statusMessage: String?

  /// Temporarily cached Apple OAuth nonce used to finalize Apple Sign-In callbacks.
  private var appleSignInNonce: String?
  private var cancellables = Set<AnyCancellable>()

  /// Indicates if the cryptography layer has prepared a nonce and is ready for sign-in.
  @Published private(set) var isReadyToSignIn = false

  /// Designated initializer injecting dependency services.
  ///
  /// - Parameters:
  ///   - authManager: Platform authenticator coordinator.
  ///   - hsm: Secure Enclave interface.
  ///   - zkLoginService: zkLogin ephemeral credentials service.
  init(authManager: AppleAuthManager, zkLoginService: ZkLoginService) {
    self.authManager = authManager
    self.zkLoginService = zkLoginService

    // Bind isReadyToSignIn to whether ZkLoginService has a pending session
    zkLoginService.$pendingZKEphemeral
      .map { $0 != nil }
      .assign(to: \.isReadyToSignIn, on: self)
      .store(in: &cancellables)
  }

  /// Asynchronously triggers the generation of an ephemeral key and nonce.
  func prepareZkNonce() async {
    do {
      _ = try await zkLoginService.prepareNonce()
    } catch {
      statusMessage = "Could not prepare sign in: \(error.localizedDescription)"
    }
  }

  /// Configures a native Apple ID authorization request payload with the active nonce.
  ///
  /// - Parameter request: The authorization request to configure.
  func prepareAppleSignInRequest(_ request: ASAuthorizationAppleIDRequest) {
    guard let nonce = zkLoginService.pendingZKEphemeral?.nonce else {
      statusMessage = "Still preparing sign in, please retry"
      return
    }
    appleSignInNonce = nonce
    authManager.prepareAppleRequest(request, nonce: nonce)
  }

  /// Finalizes the native Apple ID credential exchange and sets up the app session.
  ///
  /// - Parameters:
  ///   - result: The authorization result containing the credential or error.
  ///   - onSuccess: Callback invoked with the user name upon successful login.
  func completeAppleSignIn(
    _ result: Result<ASAuthorization, Error>, onSuccess: @escaping (String) -> Void
  ) {
    guard let nonce = appleSignInNonce else {
      statusMessage = "Apple sign in could not start"
      return
    }

    isSigningIn = true
    statusMessage = "Completing Apple sign in"

    Task {
      do {
        try await authManager.signInWithApple(result, nonce: nonce)
        let userName = "Apple account"
        statusMessage = nil
        onSuccess(userName)
      } catch {
        statusMessage = error.localizedDescription
      }

      appleSignInNonce = nil
      isSigningIn = false
    }
  }

  /// Initiates native Google Sign-In and completes the session.
  ///
  /// - Parameter onSuccess: Callback invoked with the user name upon successful login.
  func signInWithGoogle(onSuccess: @escaping (String) -> Void) {
    guard let presentationAnchor = Self.presentationAnchor() else {
      statusMessage = "Google sign in could not start"
      return
    }

    isSigningIn = true
    statusMessage = "Completing Google sign in"

    Task {
      if zkLoginService.pendingZKEphemeral == nil {
        await prepareZkNonce()
      }
      guard let nonce = zkLoginService.pendingZKEphemeral?.nonce else {
        isSigningIn = false
        return
      }

      do {
        try await authManager.signInWithGoogle(
          nonce: nonce,
          presentationAnchor: presentationAnchor
        )
        let userName = "Google account"
        statusMessage = nil
        onSuccess(userName)
      } catch {
        statusMessage = error.localizedDescription
      }

      isSigningIn = false
    }
  }

  /// Helper utility to locate the active key UIWindow for presenting modal SDK sheets.
  private static func presentationAnchor() -> UIWindow? {
    UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap(\.windows)
      .first { $0.isKeyWindow }
  }
}
