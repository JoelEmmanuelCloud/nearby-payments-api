import Foundation

public enum AuthError: String, Error, Sendable {
  case invalidPayload = "invalid_payload"
  case stateMismatch = "state_mismatch"
  case unsupportedProvider = "unsupported_provider"
  case unknown = "unknown"
}
