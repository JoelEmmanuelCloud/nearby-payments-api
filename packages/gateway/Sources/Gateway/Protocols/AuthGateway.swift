import Foundation

/// Contract for all authentication-related backend operations.
///
/// This protocol defines the complete surface area of the auth domain
/// as derived from the Postman collection. Higher-level packages (`Auth`,
/// `Attest`) depend on this protocol — never on the concrete ``APIGateway`` —
/// so they can be tested in isolation with a mock implementation.
///
/// ## Endpoint Authentication Matrix
///
/// | Endpoint            | Bearer Token | Device Headers |
/// |---------------------|:------------:|:--------------:|
/// | `serverPublicKey`   |      ✗       |       ✗        |
/// | `beginOAuth`        |      ✗       |       ✗        |
/// | `completeOAuth`     |      ✗       |       ✗        |
/// | `refresh`           |      ✓       |       ✗        |
/// | `revoke`            |      ✓       |       ✗        |
/// | `assertIntegrity`   |      ✓       |       ✓        |
/// | `issueCredential`   |      ✓       |       ✓        |
public protocol AuthGateway: Sendable {

  /// Fetches the server's Ed25519 public key for payload verification.
  ///
  /// - Unauthenticated endpoint.
  func serverPublicKey() async throws -> ServerPublicKeyResponse

  /// Initiates the OAuth flow by sending client-generated PKCE and zkLogin
  /// parameters. Returns the fully-constructed authorization URL and CSRF state.
  ///
  /// - Unauthenticated endpoint.
  func beginOAuth(request: OAuthBeginRequest) async throws -> OAuthBeginResponse

  /// Completes the OAuth flow by exchanging the authorization code for
  /// session tokens. Includes device metadata and integrity proof.
  ///
  /// - Unauthenticated endpoint (issues new tokens).
  func completeOAuth(request: OAuthCompleteRequest) async throws -> OAuthCompleteResponse

  /// Exchanges a valid refresh token for a new access/refresh token pair.
  ///
  /// - Requires: Bearer token in the `Authorization` header.
  func refresh(
    request: RefreshRequest,
    accessToken: String
  ) async throws -> RefreshResponse

  /// Revokes the current session, invalidating all associated tokens.
  ///
  /// - Requires: Bearer token in the `Authorization` header.
  func revoke(accessToken: String) async throws

  /// Submits a device integrity attestation for server-side verification.
  ///
  /// - Requires: Bearer token and device integrity headers
  ///   (`X-Device-Provider`, `X-Request-Nonce`, `X-Request-Timestamp`).
  func assertIntegrity(
    request: IntegrityRequest,
    accessToken: String,
    deviceProvider: String,
    requestNonce: String,
    requestTimestamp: String
  ) async throws

  /// Registers a hardware-backed public key for local proof signing.
  ///
  /// - Requires: Bearer token and device integrity headers.
  func issueCredential(
    request: CredentialRequest,
    accessToken: String,
    deviceProvider: String,
    requestNonce: String,
    requestTimestamp: String
  ) async throws
}
