import Foundation
import Gateway

/// A development-only provider that bypasses real hardware attestation.
///
/// This is used on simulators where App Attest and Play Integrity are unavailable.
/// It returns the `stub` identity, which the backend will accept if running in
/// development mode.
public struct StubIntegrityProvider: IntegrityProvider {

  public init() {}

  public func prepare() async throws {
    // No-op
  }

  public func attest(nonce: Data) async throws -> Gateway.DeviceIntegrity {
    return .stub
  }
}
