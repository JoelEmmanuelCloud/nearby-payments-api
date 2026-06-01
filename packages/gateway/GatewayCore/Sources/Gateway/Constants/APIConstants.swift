/// Defines static API constants, endpoint subpaths, custom HTTP header keys, and content types
/// utilized when communicating with the authentication backend.
public enum APIConstants {

  /// Current API version prefix. Bumping this propagates to every endpoint automatically.
  public static let apiVersion: String = "v1"

  /// Endpoint subpaths for authentication and credential verification actions.
  public enum Auth {
    /// GET endpoint to retrieve the backend server's public key.
    public static let serverPublicKey: String = "auth/server-public-key"
    /// POST endpoint to start the OAuth sign-in flow.
    public static let oauthBegin: String = "auth/oauth/begin"
    /// POST endpoint to complete the OAuth flow by exchanging tokens.
    public static let oauthComplete: String = "auth/oauth/complete"
    /// POST endpoint to refresh the active access token using a refresh token.
    public static let refresh: String = "auth/refresh"
    /// POST endpoint to revoke an active session token.
    public static let revoke: String = "auth/revoke"
    /// POST endpoint to submit device integrity proofs.
    public static let integrity: String = "auth/integrity"
    /// POST endpoint to request a signed device credential.
    public static let credential: String = "auth/credential"
  }

  /// Custom and standard HTTP header fields.
  public enum Headers {
    /// Content-Type header.
    public static let contentType: String = "Content-Type"
    /// Authorization header carrying the bearer access token.
    public static let authorization: String = "Authorization"
    /// Custom header identifying the device integrity platform provider (e.g. apple_app_attest, play_integrity).
    public static let deviceProvider: String = "X-Device-Provider"
    /// Custom header containing the device integrity challenge request nonce.
    public static let requestNonce: String = "X-Request-Nonce"
    /// Custom header carrying the timestamp when the request was initiated.
    public static let requestTimestamp: String = "X-Request-Timestamp"
  }

  /// Supported HTTP request content types.
  public enum ContentType {
    /// JSON content type header value.
    public static let json: String = "application/json"
  }
}
