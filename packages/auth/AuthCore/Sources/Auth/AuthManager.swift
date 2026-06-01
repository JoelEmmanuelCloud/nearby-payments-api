import Foundation
import Gateway

/// Orchestrates the client-side OAuth 2.0 flow, including beginning the authentication sequence,
/// managing state verification (such as PKCE code verifiers and CSRF states), and completing sign-in via the API gateway.
public final class AuthManager: @unchecked Sendable {
  private let platform: String
  private let osVersion: String
  private let appBundleId: String
  private let gateway: APIGateway

  private let stateLock = NSLock()
  private var activeCodeVerifier: String?
  private var activeState: String?

  /// The active URL to navigate to for web/browser authentication, updated after `signIn` begins.
  public var authURL: String?

  /// The local OAuth state verifier used to prevent CSRF attacks, updated after `signIn` begins.
  public var state: String?

  /// Initializes a new `AuthManager` with device and app metadata.
  ///
  /// - Parameters:
  ///   - platform: The operating system platform name (e.g. "ios", "android").
  ///   - osVersion: The OS version of the executing device.
  ///   - appBundleId: The application's bundle identifier or package name.
  ///   - gateway: The API gateway to perform HTTP requests.
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

  /// Begins the OAuth flow by generating PKCE verifiers (if web-based) and requesting
  /// the authorization start parameters from the API gateway.
  ///
  /// - Parameters:
  ///   - provider: The OAuth provider (e.g. `.google`, `.apple`).
  ///   - authType: The authentication mode (web vs native).
  ///   - zkLoginNonce: A one-time nonce value used for zkLogin integration.
  /// - Returns: An `OAuthBeginResponse` containing the redirect URL and verification state.
  /// - Throws: An error if the gateway request fails.
  public func signIn(
    provider: OAuthProvider,
    authType: AuthType,
    zkLoginNonce: String
  ) async throws -> OAuthBeginResponse {
    let verifier: String
    var challenge: String? = nil
    var codeChallengeMethod: String? = nil

    switch authType {
    case .web:
      verifier = PKCE.generateCodeVerifier()
      challenge = PKCE.generateCodeChallenge(verifier: verifier)
      codeChallengeMethod = "S256"

    case .native:
      verifier = ""
    }

    let request = OAuthBeginRequest(
      flowType: authType,
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

  /// Completes a native OAuth sign-in (e.g., via native Apple Sign In or Google Sign In on Android).
  ///
  /// - Parameters:
  ///   - provider: The identity provider utilized (Google or Apple).
  ///   - idToken: The ID token returned by the native identity provider.
  ///   - state: The authentication flow state parameter.
  ///   - authorizationCode: An optional server authorization code if requested by the client.
  ///   - deviceIntegrity: The unified device integrity proof structure (App Attest, Play Integrity, etc.).
  /// - Returns: An `OAuthCompleteResponse` containing the user's session credentials.
  /// - Throws: `AuthError.stateMismatch` if the state parameter is invalid or has already been used.
  public func completeNativeSignIn(
    provider: OAuthProvider,
    idToken: String,
    state: String,
    authorizationCode: String?,
    deviceIntegrity: DeviceIntegrity
  ) async throws -> OAuthCompleteResponse {
    _ = try verifyState(state: state)
    return try await complete(
      payload: .native(
        idToken: idToken,
        state: state,
        authorizationCode: authorizationCode
      ),
      integrity: deviceIntegrity
    )
  }

  /// Completes a web-redirect-based OAuth sign-in flow.
  ///
  /// - Parameters:
  ///   - provider: The identity provider utilized.
  ///   - code: The authorization code returned by the provider redirect callback.
  ///   - state: The state parameter passed in the redirect callback.
  ///   - deviceIntegrity: The unified device integrity proof structure.
  /// - Returns: An `OAuthCompleteResponse` containing the user session credentials.
  /// - Throws: `AuthError.stateMismatch` if the state does not match the active session request.
  public func completeWebSignIn(
    provider: OAuthProvider,
    code: String,
    state: String,
    deviceIntegrity: DeviceIntegrity
  ) async throws -> OAuthCompleteResponse {
    let codeVerifier = try verifyState(state: state)

    return try await complete(
      payload: .web(
        code: code,
        state: state,
        codeVerifier: codeVerifier
      ),
      integrity: deviceIntegrity
    )
  }

  /// Verifies that the incoming state matches the generated state and resets active state parameters.
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

  /// Finalizes the OAuth flow by exchanging the credentials and integrity proof for session tokens.
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
