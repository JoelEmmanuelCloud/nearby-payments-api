public enum APIConstants {

  public static let apiVersion = "v1"

  public enum Auth {
    public static let serverPublicKey = "auth/server-public-key"
    public static let oauthBegin = "auth/oauth/begin"
    public static let oauthComplete = "auth/oauth/complete"
    public static let refresh = "auth/refresh"
    public static let revoke = "auth/revoke"
    public static let integrity = "auth/integrity"
    public static let credential = "auth/credential"
  }

  public enum Headers {
    public static let contentType = "Content-Type"
    public static let authorization = "Authorization"
    public static let deviceProvider = "X-Device-Provider"
    public static let requestNonce = "X-Request-Nonce"
    public static let requestTimestamp = "X-Request-Timestamp"
  }

  public enum ContentType {
    public static let json = "application/json"
  }
}
