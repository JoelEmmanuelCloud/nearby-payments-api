import Foundation
import Gateway

public final class AuthManager: @unchecked Sendable {
  private let platform: String
  private let osVersion: String
  private let appBundleId: String
  private let gateway: APIGateway

  private let stateLock = NSLock()
  private var activeCodeVerifier: String?
  private var activeState: String?

  // Properties queried synchronously by the native host in the browser callback
  public var authURL: String?
  public var state: String?

  public init(
    platform: String,
    osVersion: String,
    appBundleId: String,
    gateway: APIGateway
  ) {
    self.platform = platform
    self.osVersion = osVersion
    self.appBundleId = appBundleId
    self.gateway = gateway
  }

  public func signIn(
    provider: OAuthProvider,
    authType: AuthType,
    zkLoginNonce: String
  ) async throws -> OAuthBeginResponse {
    let verifier: String
    let challenge: String
    let codeChallengeMethod: String

    switch authType {
    case .web:
      verifier = PKCE.generateCodeVerifier()
      challenge = PKCE.generateCodeChallenge(verifier: verifier)
      codeChallengeMethod = "S256"

    case .native:
      verifier = ""
      challenge = ""
      codeChallengeMethod = "Exclude"
    }

    let request = OAuthBeginRequest(
      provider: provider,
      codeChallenge: challenge,
      codeChallengeMethod: codeChallengeMethod,
      zkLoginNonce: zkLoginNonce
    )

    let response = try await gateway.beginOAuth(request: request)

    stateLock.withLock {
      self.activeCodeVerifier = verifier
      self.activeState = response.state
      self.authURL = response.authURL
      self.state = response.state
    }

    return response
  }

  public func completeNativeSignIn(
    provider: OAuthProvider,
    idToken: String,
    state: String,
    authorizationCode: String?,
    integrityProvider: String,
    integrityKeyId: String?,
    integrityAssertion: String?,
    integrityToken: String?,
    integrityClientDataHash: String?
  ) async throws -> OAuthCompleteResponse {
    _ = try verifyState(state: state)
    return try await complete(
      payload: .native(
        idToken: idToken,
        state: state,
        authorizationCode: authorizationCode
      ),
      integrity: DeviceIntegrity(
        provider: integrityProvider,
        keyId: integrityKeyId,
        assertion: integrityAssertion,
        token: integrityToken,
        clientDataHash: integrityClientDataHash
      )
    )
  }

  public func completeWebSignIn(
    provider: OAuthProvider,
    code: String,
    state: String,
    integrityProvider: String,
    integrityKeyId: String?,
    integrityAssertion: String?,
    integrityToken: String?,
    integrityClientDataHash: String?
  ) async throws -> OAuthCompleteResponse {
    let codeVerifier = try verifyState(state: state)

    return try await complete(
      payload: .web(
        code: code,
        state: state,
        codeVerifier: codeVerifier
      ),
      integrity: DeviceIntegrity(
        provider: integrityProvider,
        keyId: integrityKeyId,
        assertion: integrityAssertion,
        token: integrityToken,
        clientDataHash: integrityClientDataHash
      )
    )
  }

  private func verifyState(state: String) throws -> String {
    let verifier = stateLock.withLock {
      defer {
        activeCodeVerifier = nil
        activeState = nil
        authURL = nil
        self.state = nil
      }
      return (state == activeState) ? activeCodeVerifier : nil
    }
    guard let verifier else {
      throw AuthError.stateMismatch
    }
    return verifier
  }

  private func complete(
    payload: AuthFlowPayload,
    integrity: DeviceIntegrity
  ) async throws -> OAuthCompleteResponse {
    let request = OAuthCompleteRequest(
      platform: platform,
      osVersion: osVersion,
      appBundleId: appBundleId,
      deviceIntegrity: integrity,
      payload: payload
    )

    let gatewayResponse = try await gateway.completeOAuth(request: request)

    return gatewayResponse
  }
}
