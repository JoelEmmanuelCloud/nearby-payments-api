#if os(iOS)
  import AuthenticationServices
  import Crypto
  import DeviceIntegrity
  import Foundation
  import Gateway
  import GoogleSignIn
  import HSM
  import Storage

  /// iOS platform-specific coordinator that orchestrates native OAuth sign-in operations,
  /// including native Sign in with Apple and native Google Sign-In.
  ///
  /// This class is explicitly excluded from the JNI Java bridge and only compiles/executes on iOS devices.
  public final class AppleAuthManager: Sendable {
    private let auth: AuthManager
    public let sessionManager: SessionManager
    private let integrityProvider: IntegrityProvider

    /// Initializes `AppleAuthManager` with an upstream-owned gateway and session manager.
    ///
    /// The session manager (and the HSM it wraps) is constructed by the caller so the same
    /// HSM instance can be shared higher up — e.g. to back the zkLogin ephemeral key — rather
    /// than being recreated internally. Mirrors the Android `GoogleAuthManager` initializer.
    ///
    /// - Parameters:
    ///   - gateway: The HTTP client API Gateway instance.
    ///   - sessionManager: The session manager owning token storage, the HSM, and refresh/revoke.
    ///   - bundleId: The iOS app bundle identifier.
    public init(
      gateway: APIGateway,
      sessionManager: SessionManager,
      bundleId: String
    ) {
      self.integrityProvider = StubIntegrityProvider()
      self.sessionManager = sessionManager

      let platform = "ios"
      let osVersion = ProcessInfo.processInfo.operatingSystemVersionString

      self.auth = AuthManager(
        platform: platform,
        osVersion: osVersion,
        appBundleId: bundleId,
        gateway: gateway
      )
    }

    /// Attests device integrity bound to a SHA-256 hash of the nonce and current session state.
    private func attestIntegrity(nonce: String, state: String) async throws
      -> Gateway.DeviceIntegrity
    {
      let combinedString = nonce + state
      let hash = PKCE.hash(combinedString)
      return try await integrityProvider.attest(nonce: hash)
    }

    /// Prepares an `ASAuthorizationAppleIDRequest` with necessary scopes and hashed nonce parameter.
    ///
    /// - Parameters:
    ///   - request: The Apple ID authorization request to prepare.
    ///   - nonce: The raw nonce string generated for authentication.
    @MainActor
    public func prepareAppleRequest(
      _ request: ASAuthorizationAppleIDRequest,
      nonce: String
    ) {
      request.requestedScopes = [.email]
      request.nonce = PKCE.hashBase64URL(nonce)
    }

    /// Completes native Sign in with Apple after receiving the authorization result from the UI framework.
    ///
    /// - Parameters:
    ///   - result: The authorization result containing the credential or error.
    ///   - nonce: The raw authentication nonce.
    /// - Throws: An error if authorization fails, the payload is invalid, or server complete request fails.
    @MainActor
    public func signInWithApple(
      _ result: Result<ASAuthorization, Error>,
      nonce: String
    ) async throws {
      let response = try await auth.signIn(provider: .apple, authType: .native, zkLoginNonce: nonce)

      let authorization = try result.get()

      guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
        let identityTokenData = credential.identityToken,
        let identityToken = String(data: identityTokenData, encoding: .utf8)
      else {
        throw AuthError.invalidPayload
      }

      let authCode = credential.authorizationCode.flatMap {
        String(data: $0, encoding: .utf8)
      }

      let integrityAssertion = try await attestIntegrity(nonce: nonce, state: response.state)
      let completeResponse = try await auth.completeNativeSignIn(
        provider: .apple,
        idToken: identityToken,
        state: response.state,
        authorizationCode: authCode,
        deviceIntegrity: integrityAssertion
      )

      try sessionManager.saveSession(response: completeResponse, provider: .apple, maxEpoch: 0)
    }

    /// Triggers native Google Sign-In with a presenting root view controller and completes session setup.
    ///
    /// - Parameters:
    ///   - nonce: The zkLogin target identity nonce.
    ///   - presentationAnchor: The UI window presenting the Google Sign-In modal view.
    /// - Throws: An error if the sign-in modal is dismissed, network fails, or session setup encounters issues.
    @MainActor
    public func signInWithGoogle(nonce: String, presentationAnchor: ASPresentationAnchor)
      async throws
    {
      let response = try await auth.signIn(
        provider: .google, authType: .native, zkLoginNonce: nonce)

      guard let rootViewController = presentationAnchor.rootViewController else {
        throw AuthError.unknown
      }

      let signInResult = try await GIDSignIn.sharedInstance.signIn(
        withPresenting: rootViewController,
        hint: nil,
        additionalScopes: nil,
        nonce: nonce
      )

      guard let idToken = signInResult.user.idToken?.tokenString else {
        throw AuthError.invalidPayload
      }

      let integrityAssertion = try await attestIntegrity(nonce: nonce, state: response.state)

      let completeResponse = try await auth.completeNativeSignIn(
        provider: .google,
        idToken: idToken,
        state: response.state,
        authorizationCode: signInResult.serverAuthCode,
        deviceIntegrity: integrityAssertion
      )

      try sessionManager.saveSession(response: completeResponse, provider: .google, maxEpoch: 0)
    }

    /// Revokes the current session server-side, clears local credentials, and detaches
    /// the identity provider.
    ///
    /// After the backend session is revoked and local state cleared, the corresponding
    /// provider is told the app no longer holds the session. For Google this calls
    /// `disconnect()`, which revokes the OAuth grant. Apple offers no client-side
    /// revoke API, so its grant must be revoked server-side via `/auth/revoke`.
    @MainActor
    public func signOut() async throws {
      let provider = try await sessionManager.revokeSession()

      switch provider {
      case .google:
        // `disconnect()` signs out and revokes all OAuth2 scope grants at Google.
        // Best-effort: a failure here must not resurrect the already-cleared session.
        try? await GIDSignIn.sharedInstance.disconnect()
      case .apple, .none:
        // No client-side Apple revoke API; backend handles `/auth/revoke`.
        break
      }
    }

    /// Observes live Sign in with Apple credential revocation and signs the user out.
    ///
    /// Apple posts `credentialRevokedNotification` when the user revokes the app's
    /// Sign in with Apple credential (e.g. from Settings) while the app is running.
    /// This catches provider revocation while the app is running without attempting
    /// any silent provider sign-in. The session is revoked and cleared before
    /// `onRevoked` is invoked.
    ///
    /// - Parameter onRevoked: Called on the main actor after the session is cleared,
    ///   so the app can route to sign-in.
    /// - Returns: The observer token. Retain it for as long as observation is desired
    ///   and remove it from `NotificationCenter.default` to stop observing.
    @discardableResult
    public func observeAppleCredentialRevocation(
      onRevoked: @escaping @Sendable () -> Void
    ) -> NSObjectProtocol {
      NotificationCenter.default.addObserver(
        forName: ASAuthorizationAppleIDProvider.credentialRevokedNotification,
        object: nil,
        queue: .main
      ) { [weak self] _ in
        Task { @MainActor in
          try? await self?.signOut()
          onRevoked()
        }
      }
    }

  }
#endif
