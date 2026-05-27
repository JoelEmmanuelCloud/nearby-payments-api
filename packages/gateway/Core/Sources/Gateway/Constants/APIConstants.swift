public enum APIConstants {

  /// Current API version prefix. Bumping this propagates to every endpoint automatically.
  public static let apiVersion: String = "v1"

  public enum Auth {
    public static let serverPublicKey: String = "auth/server-public-key"
    public static let oauthBegin: String = "auth/oauth/begin"
    public static let oauthComplete: String = "auth/oauth/complete"
    public static let refresh: String = "auth/refresh"
    public static let revoke: String = "auth/revoke"
    public static let integrity: String = "auth/integrity"
    public static let credential: String = "auth/credential"
  }

  public enum Headers {
    public static let contentType: String = "Content-Type"
    public static let authorization: String = "Authorization"
    public static let deviceProvider: String = "X-Device-Provider"
    public static let requestNonce: String = "X-Request-Nonce"
    public static let requestTimestamp: String = "X-Request-Timestamp"
  }

  public enum ContentType {
    public static let json: String = "application/json"
  }
}
