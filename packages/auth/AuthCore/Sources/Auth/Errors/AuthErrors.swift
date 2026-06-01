import Foundation

/// Errors that can occur during the authentication process.
public enum AuthError: String, Error, Sendable {
  /// The authentication payload or response structure from the identity provider was invalid.
  case invalidPayload = "invalid_payload"

  /// The returned OAuth state parameter does not match the locally generated state, indicating potential CSRF.
  case stateMismatch = "state_mismatch"

  /// The requested identity provider is not supported on this platform.
  case unsupportedProvider = "unsupported_provider"

  /// An unknown or unexpected error occurred.
  case unknown = "unknown"
}
