/// Represents the authentication type used to begin the OAuth flow.
public enum AuthType: String, Codable, Sendable, CaseIterable {
  /// Web-based OAuth flow using a browser or custom tab redirect.
  case web = "web"

  /// Native platform-based OAuth flow (e.g., native Google Sign-In or Sign in with Apple).
  case native = "native"
}
