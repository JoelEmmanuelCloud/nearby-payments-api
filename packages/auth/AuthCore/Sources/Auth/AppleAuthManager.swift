#if os(iOS)
  import AuthenticationServices
  import Crypto
  import DeviceIntegrity
  import Foundation
  import Gateway
  import GoogleSignIn
  import HSM
  import Storage

  public final class AppleAuthManager: NSObject, ASAuthorizationControllerDelegate,
    ASAuthorizationControllerPresentationContextProviding,
    ASWebAuthenticationPresentationContextProviding, Sendable
  {
    private let auth: AuthManager
    private let sessionManager: SessionManager
    private let integrityProvider: IntegrityProvider

    private let continuationLock = NSLock()
    private var activeAnchor: ASPresentationAnchor?
    private var credentialContinuation:
      CheckedContinuation<(idToken: String, authCode: String?), Error>?

    public init(
      gateway: APIGateway,
      storage: KeychainProvider,
      hsm: SecureEnclaveHSM,
      bundleId: String
    ) {
      self.integrityProvider = StubIntegrityProvider()
      self.sessionManager = SessionManager(storage: storage, hsm: hsm)

      let platform = "ios"
      let osVersion = ProcessInfo.processInfo.operatingSystemVersionString

      self.auth = AuthManager(
        platform: platform,
        osVersion: osVersion,
        appBundleId: bundleId,
        gateway: gateway
      )
    }

    private func attestIntegrity(nonce: String, state: String) async throws
      -> Gateway.DeviceIntegrity
    {
      let combinedString = nonce + state
      let hash = PKCE.hash(combinedString)
      return try await integrityProvider.attest(nonce: hash)
    }

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
        integrityProvider: integrityAssertion.provider,
        integrityKeyId: integrityAssertion.keyId,
        integrityAssertion: integrityAssertion.assertion,
        integrityToken: integrityAssertion.token,
        integrityClientDataHash: integrityAssertion.clientDataHash
      )

      try sessionManager.saveSession(response: completeResponse)
    }

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
        integrityProvider: integrityAssertion.provider,
        integrityKeyId: integrityAssertion.keyId,
        integrityAssertion: integrityAssertion.assertion,
        integrityToken: integrityAssertion.token,
        integrityClientDataHash: integrityAssertion.clientDataHash
      )

      try sessionManager.saveSession(response: completeResponse)
    }

    public func presentationAnchor(for controller: ASAuthorizationController)
      -> ASPresentationAnchor
    {
      return activeAnchor ?? ASPresentationAnchor()
    }

    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor
    {
      return activeAnchor ?? ASPresentationAnchor()
    }
  }
#endif
