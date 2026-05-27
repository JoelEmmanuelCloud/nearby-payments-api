import Foundation
import Gateway

/// A platform-agnostic interface for generating device attestation proofs.
///
/// Implementations of this protocol securely bind a request payload (via a nonce)
/// to the device's hardware identity.
public protocol IntegrityProvider: Sendable {

  /// Prepares the attestation provider.
  ///
  /// On Android, this warms up the Play Integrity API (Standard mode).
  /// On iOS, this ensures DeviceCheck is supported.
  func prepare() async throws

  /// Generates an attestation proof bound to the given nonce.
  ///
  /// - Parameter nonce: A one-time challenge or a hash of a payload, ensuring the
  ///                    resulting token cannot be replayed.
  /// - Returns: A `DeviceIntegrity` structure containing the proof token or assertion.
  func attest(nonce: Data) async throws -> Gateway.DeviceIntegrity
}
