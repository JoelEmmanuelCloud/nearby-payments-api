/// Centralised API constants derived from the backend's Postman collection.
///
/// All route paths are relative to the base URL injected via ``GatewayConfiguration``.
/// Header keys follow the conventions established in the backend's integrity middleware.
public enum APIConstants {

  /// Current API version prefix. Bumping this propagates to every endpoint automatically.
  public static let apiVersion = "v1"

  // MARK: - Auth Routes

  /// Route paths for the authentication domain.
  ///
  /// Each path is relative to `<baseURL>/<apiVersion>/`.
  /// The backend treats `begin` and `complete` as unauthenticated;
  /// all others require a valid bearer token.
  public enum Auth {
    public static let serverPublicKey = "auth/server-public-key"
    public static let oauthBegin = "auth/oauth/begin"
    public static let oauthComplete = "auth/oauth/complete"
    public static let refresh = "auth/refresh"
    public static let revoke = "auth/revoke"
    public static let integrity = "auth/integrity"
    public static let credential = "auth/credential"
  }

  // MARK: - Standard Headers

  /// Header keys consumed by the backend's device-integrity middleware.
  ///
  /// These are injected automatically by ``APIGateway`` for endpoints
  /// that require device attestation proof alongside the bearer token.
  public enum Headers {
    public static let contentType = "Content-Type"
    public static let authorization = "Authorization"
    public static let deviceProvider = "X-Device-Provider"
    public static let requestNonce = "X-Request-Nonce"
    public static let requestTimestamp = "X-Request-Timestamp"
  }

  // MARK: - Content Types

  public enum ContentType {
    public static let json = "application/json"
  }
}
