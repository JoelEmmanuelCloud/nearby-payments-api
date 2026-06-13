import Foundation

/// Errors that can occur during the hardware attestation and integrity verification process.
public enum AttestError: Error {
  /// Hardware-backed device attestation is not supported on this platform or device configuration.
  case notSupported
}

extension AttestError {
  /// Stable, globally-unique, machine-readable code for each case.
  public enum Code: String, Sendable, CaseIterable {
    case notSupported = "device_integrity.not_supported"
  }

  /// The stable code identifying this error.
  public var code: Code {
    switch self {
    case .notSupported: .notSupported
    }
  }
}

extension AttestError: CustomStringConvertible {
  /// String form is the `code` raw value, so the exact code survives the swift-java bridge.
  public var description: String { code.rawValue }
}
