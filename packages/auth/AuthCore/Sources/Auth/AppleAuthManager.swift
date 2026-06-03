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
  /// including native Sign in with Apple, native Google Sign-In, and UI presentation context anchoring.
  ///
  /// This class is explicitly excluded from the JNI Java bridge and only compiles/executes on iOS devices.
  public final class AppleAuthManager: NSObject, ASAuthorizationControllerDelegate,
    ASAuthorizationControllerPresentationContextProviding,
    ASWebAuthenticationPresentationContextProviding, Sendable
  {
    private let auth: AuthManager
    public let sessionManager: SessionManager
    private let integrityProvider: IntegrityProvider

    private let continuationLock = NSLock()
    private var activeAnchor: ASPresentationAnchor?
    private var credentialContinuation:
      CheckedContinuation<(idToken: String, authCode: String?), Error>?

    /// Initializes `AppleAuthManager` with custom gateway, storage, and HSM providers.
    ///
    /// - Parameters:
    ///   - gateway: The HTTP client API Gateway instance.
    ///   - storage: Keychain provider for secure token storage.
    ///   - hsm: Secure Enclave hardware key provider.
    ///   - bundleId: The iOS app bundle identifier.
    public init(
      gateway: APIGateway,
      storage: KeychainProvider,
      hsm: SecureEnclaveHSM,
      bundleId: String
    ) {
      self.integrityProvider = StubIntegrityProvider()
      self.sessionManager = SessionManager(storage: storage, hsm: hsm, gateway: gateway)

      let platform = "ios"
      let osVersion = ProcessInfo.processInfo.operatingSystemVersionString

      self.auth = AuthManager(
        platform: platform,
        osVersion: osVersion,
        appBundleId: bundleId,
        gateway: gateway
      )
    }

    /// Convenience initializer constructing dependencies from baseURL and version parameters.
    ///
    /// - Parameters:
    ///   - baseURLString: Root URL string of the authentication backend server.
    ///   - apiVersion: The target backend API version string (e.g. "v1").
    ///   - bundleId: The application's bundle identifier.
    /// - Throws: `GatewayError` if the baseURLString is invalid.
    public convenience init(
      baseURLString: String,
      apiVersion: String,
      bundleId: String
    ) throws {
      let gateway = try APIGateway(baseURLString: baseURLString, apiVersion: apiVersion)
      self.init(
        gateway: gateway,
        storage: KeychainProvider(),
        hsm: SecureEnclaveHSM(),
        bundleId: bundleId
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
      request.requestedScopes = [.fullName, .email]
      request.nonce = PKCE.hash(nonce).base64urlEncodedString()
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

    /// Revokes the current session server-side and clears local credentials.
    public func signOut() async throws {
      try await sessionManager.revokeSession()
    }

    /// Protocol method returns the active presentation window for the authorization dialog.
    public func presentationAnchor(for controller: ASAuthorizationController)
      -> ASPresentationAnchor
    {
      return activeAnchor ?? ASPresentationAnchor()
    }

    /// Protocol method returns the active presentation window for the web authentication session.
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor
    {
      return activeAnchor ?? ASPresentationAnchor()
    }
  }
#endif
