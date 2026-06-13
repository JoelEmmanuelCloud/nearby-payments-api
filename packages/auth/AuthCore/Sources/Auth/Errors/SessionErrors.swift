import Foundation

/// Errors produced by session persistence, refresh, and revocation flows.
public enum SessionError: String, Error, Sendable {
  /// The persisted session expired or is no longer usable.
  case sessionExpired = "session_expired"

  /// The operation requires a gateway-enabled session manager.
  case gatewayUnavailable = "gateway_unavailable"

  /// The gateway was not able to revoke the session.
  case gatewayRevokeFailed = "gateway_revoke_failed"
}

extension SessionError {
  /// Stable, globally-unique, machine-readable code for each case. Use `Code(rawValue:)` to map a
  /// bridged code string back to the error kind.
  public enum Code: String, Sendable, CaseIterable {
    case sessionExpired = "auth.session_expired"
    case gatewayUnavailable = "auth.gateway_unavailable"
    case gatewayRevokeFailed = "auth.gateway_revoke_failed"
  }

  /// The stable code identifying this error.
  public var code: Code {
    switch self {
    case .sessionExpired: .sessionExpired
    case .gatewayUnavailable: .gatewayUnavailable
    case .gatewayRevokeFailed: .gatewayRevokeFailed
    }
  }
}

extension SessionError: CustomStringConvertible {
  /// The error's string form is its `code` raw value, so the swift-java async bridge (which
  /// stringifies thrown errors via `String(describing:)`) carries the exact code across JNI,
  /// recoverable on the Kotlin side via `SessionError.Code(rawValue:)`.
  public var description: String { code.rawValue }
}
