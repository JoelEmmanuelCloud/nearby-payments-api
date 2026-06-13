import Foundation
import Gateway

/// A development-only provider that bypasses real hardware attestation.
///
/// This is used on simulators where App Attest and Play Integrity are unavailable.
/// It returns the `stub` identity, which the backend will accept if running in
/// development mode.
public struct StubIntegrityProvider: IntegrityProvider {

  /// Initializes a new `StubIntegrityProvider`.
  public init() {}

  /// No-op preparation since stub integrity provider requires no warm-up resources.
  public func prepare() async throws {
    // No-op
  }

  /// Instantly generates a stub integrity attestation response bypassing hardware checks.
  ///
  /// - Parameter nonce: Unused challenge nonce.
  /// - Returns: A static `DeviceIntegrity.stub` instance accepted by the backend in development configuration.
  public func attest(nonce: Data) async throws -> Gateway.DeviceIntegrity {
    return .stub
  }

}
