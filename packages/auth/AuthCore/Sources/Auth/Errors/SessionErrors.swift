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
