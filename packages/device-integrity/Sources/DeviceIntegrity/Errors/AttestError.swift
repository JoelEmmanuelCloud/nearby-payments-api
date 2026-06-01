import Foundation

/// Errors that can occur during the hardware attestation and integrity verification process.
public enum AttestError: Error {
  /// Hardware-backed device attestation is not supported on this platform or device configuration.
  case notSupported
}
