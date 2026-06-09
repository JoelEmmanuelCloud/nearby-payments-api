/// Errors specific to the Identity orchestration layer.
public enum IdentityError: String, Error, Sendable {
  /// No active authenticated session was found.
  case unauthorized = "accesstoken_denied"

  /// The SuiNS name resolution failed or returned unexpected results.
  case nameServiceResolutionFailed = "name_service_resolution_failed"

  /// An underlying API Gateway request failed.
  case gatewayFailure = "gateway_failure"

  /// The name registration task timed out or was rejected.
  case registrationFailed = "registration_failed"
}

extension IdentityError {
  /// Stable, globally-unique, machine-readable code for each case (the case kind, not its payload).
  public enum Code: String, Sendable, CaseIterable {
    case unauthorized = "identity.unauthorized"
    case nameServiceResolutionFailed = "identity.name_service_resolution_failed"
    case gatewayFailure = "identity.gateway_failure"
    case registrationFailed = "identity.registration_failed"
  }

  /// The stable code identifying this error's kind.
  public var code: Code {
    switch self {
    case .unauthorized: .unauthorized
    case .nameServiceResolutionFailed: .nameServiceResolutionFailed
    case .gatewayFailure: .gatewayFailure
    case .registrationFailed: .registrationFailed
    }
  }
}

extension IdentityError: CustomStringConvertible {
  /// String form is the `code` raw value, so the exact code survives the swift-java bridge.
  public var description: String { code.rawValue }
}
