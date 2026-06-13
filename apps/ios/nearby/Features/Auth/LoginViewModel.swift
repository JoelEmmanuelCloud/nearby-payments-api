import Auth
import AuthenticationServices
import Combine
import Foundation
import HSM
import UI
import UIKit

/// UI state controller coordinating Google and Apple OAuth processes on iOS.
///
/// `LoginViewModel` prepares secure ephemeral keys and nonces for zkLogin, configures OAuth requests,
/// maps OS callbacks to authentication services, and reports active sign-in status messages to the view.
@MainActor
final class LoginViewModel: ObservableObject {
  private let authManager: AppleAuthManager
  private let zkLoginService: ZkLoginService
  private let toastController: ToastController

  /// Indicates whether an active network sign-in operation is currently in progress.
  @Published private(set) var isSigningIn = false

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
  init(
    authManager: AppleAuthManager, zkLoginService: ZkLoginService, toastController: ToastController
  ) {
    self.authManager = authManager
    self.zkLoginService = zkLoginService
    self.toastController = toastController

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
      toastController.show("Could not prepare sign in", tone: .warning)
    }
  }

  /// Configures a native Apple ID authorization request payload with the active nonce.
  ///
  /// - Parameter request: The authorization request to configure.
  func prepareAppleSignInRequest(_ request: ASAuthorizationAppleIDRequest) {
    guard let nonce = zkLoginService.pendingZKEphemeral?.nonce else {
      toastController.show("Still preparing sign in, please retry", tone: .neutral)
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
      toastController.show("Apple sign in could not start", tone: .danger)
      return
    }

    isSigningIn = true

    Task {
      do {
        try await authManager.signInWithApple(result, nonce: nonce)
        let userName = "Apple account"
        onSuccess(userName)
      } catch {
        toastController.show(error.localizedDescription, tone: .danger)
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
      toastController.show("Google sign in could not start", tone: .danger)
      return
    }

    isSigningIn = true

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
        onSuccess(userName)
      } catch {
        toastController.show(error.localizedDescription, tone: .danger)
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
