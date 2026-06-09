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

extension AuthError {
  /// Stable, globally-unique, machine-readable code for each case.
  public enum Code: String, Sendable, CaseIterable {
    case invalidPayload = "auth.invalid_payload"
    case stateMismatch = "auth.state_mismatch"
    case unsupportedProvider = "auth.unsupported_provider"
    case unknown = "auth.unknown"
  }

  /// The stable code identifying this error.
  public var code: Code {
    switch self {
    case .invalidPayload: .invalidPayload
    case .stateMismatch: .stateMismatch
    case .unsupportedProvider: .unsupportedProvider
    case .unknown: .unknown
    }
  }
}

extension AuthError: CustomStringConvertible {
  /// String form is the `code` raw value, so the exact code survives the swift-java bridge.
  public var description: String { code.rawValue }
}
