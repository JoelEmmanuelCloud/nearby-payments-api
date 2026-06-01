import Foundation

/// Defines a protocol for communicating with the authentication backend service.
///
/// Implementations of this protocol are responsible for server-side key retrieval, OAuth handshakes,
/// token rotations, session revocation, integrity verification, and secure credential issuance.
public protocol AuthGateway: Sendable {

  /// Fetches the public key used by the backend to sign device credentials.
  ///
  /// - Returns: A response containing the server public key string.
  /// - Throws: An error if fetching or decoding fails.
  func serverPublicKey() async throws -> ServerPublicKeyResponse

  /// Begins the OAuth flow by registering a challenge and nonce.
  ///
  /// - Parameter request: The oauth initialization parameters.
  /// - Returns: A response containing the authorization URL and state token.
  /// - Throws: An error if the request fails.
  func beginOAuth(request: OAuthBeginRequest) async throws -> OAuthBeginResponse

  /// Completes the sign-in sequence, exchanging proof details for session credentials.
  ///
  /// - Parameter request: Completed sign-in parameters and device integrity proof.
  /// - Returns: Session response containing OAuth access and refresh tokens.
  /// - Throws: An error if verification fails.
  func completeOAuth(request: OAuthCompleteRequest) async throws -> OAuthCompleteResponse

  /// Renews an expired access token using an active refresh token.
  ///
  /// - Parameters:
  ///   - request: Token refresh request details.
  ///   - accessToken: The current authorization token.
  /// - Returns: The response containing rotated token strings.
  /// - Throws: An error if refresh fails.
  func refresh(
    request: RefreshRequest,
    accessToken: String
  ) async throws -> RefreshResponse

  /// Revokes an active session token, logging the user out server-side.
  ///
  /// - Parameter accessToken: The token to revoke.
  /// - Throws: An error if revocation fails.
  func revoke(accessToken: String) async throws

  /// Submits device integrity attestation assertions for separate validation.
  ///
  /// - Parameters:
  ///   - request: Integrity assertion and request timestamp.
  ///   - accessToken: Active access token.
  ///   - deviceProvider: The name of the device provider (e.g. apple_app_attest, play_integrity).
  ///   - requestNonce: The verification nonce challenge.
  ///   - requestTimestamp: Current time indicating assertion timestamp.
  /// - Throws: An error if verification fails.
  func assertIntegrity(
    request: IntegrityRequest,
    accessToken: String,
    deviceProvider: String,
    requestNonce: String,
    requestTimestamp: String
  ) async throws

  /// Requests the issuance of a signed device credential linked to a client proof key.
  ///
  /// - Parameters:
  ///   - request: The credential request parameters.
  ///   - accessToken: Active access token.
  ///   - deviceProvider: The name of the device integrity provider.
  ///   - requestNonce: The verification nonce challenge.
  ///   - requestTimestamp: Current timestamp.
  /// - Returns: The issued and signed `DeviceCredential` structure.
  /// - Throws: An error if credential generation or validation fails.
  func issueCredential(
    request: CredentialRequest,
    accessToken: String,
    deviceProvider: String,
    requestNonce: String,
    requestTimestamp: String
  ) async throws -> DeviceCredential
}
