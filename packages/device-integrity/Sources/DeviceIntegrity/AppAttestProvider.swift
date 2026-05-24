import DeviceCheck
import DeviceIntegrityShared
import Foundation
import Gateway

/// An implementation of `IntegrityProvider` backed by Apple's `DCAppAttestService`.
///
/// This provider uses a local hardware-backed key to generate an attestation statement
/// (for the first request) and assertions (for subsequent requests).
public actor AppAttestProvider: IntegrityProvider {

  private let service = DCAppAttestService.shared

  /// A UserDefaults key to store the generated App Attest key identifier.
  private let keyIdDefaultsKey = "com.variance.nearby.appattest.keyId"

  public init() {}

  public func prepare() async throws {
    guard service.isSupported else {
      throw AttestError.notSupported
    }
  }

  public func attest(nonce: Data) async throws -> Gateway.DeviceIntegrity {
    guard service.isSupported else {
      throw AttestError.notSupported
    }

    let clientDataHash = Data(nonce)  // In practice, Apple requires a SHA-256 hash

    // If we already have a key, we generate an assertion.
    if let keyId = UserDefaults.standard.string(forKey: keyIdDefaultsKey) {
      do {
        let assertion = try await service.generateAssertion(keyId, clientDataHash: clientDataHash)
        return Gateway.DeviceIntegrity(
          provider: "apple_app_attest",
          keyId: keyId,
          assertion: assertion.base64EncodedString(),
          token: nil,
          clientDataHash: clientDataHash.base64EncodedString()
        )
      } catch {
        // If assertion fails, the key might be invalidated (e.g. app reinstalled, OS updated).
        // We should fallback to generating a new key.
        UserDefaults.standard.removeObject(forKey: keyIdDefaultsKey)
        return try await generateNewAttestation(clientDataHash: clientDataHash)
      }
    } else {
      // First time: generate a new key and attestation object.
      return try await generateNewAttestation(clientDataHash: clientDataHash)
    }
  }

  private func generateNewAttestation(clientDataHash: Data) async throws -> Gateway.DeviceIntegrity
  {
    let keyId = try await service.generateKey()
    UserDefaults.standard.set(keyId, forKey: keyIdDefaultsKey)

    let attestation = try await service.attestKey(keyId, clientDataHash: clientDataHash)

    return Gateway.DeviceIntegrity(
      provider: "apple_app_attest",
      keyId: keyId,
      assertion: attestation.base64EncodedString(),
      token: nil,
      clientDataHash: clientDataHash.base64EncodedString()
    )
  }

}
