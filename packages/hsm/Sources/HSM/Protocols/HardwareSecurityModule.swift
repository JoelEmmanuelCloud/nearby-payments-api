import Foundation

/// Defines a platform-agnostic interface for a hardware-backed security module.
///
/// Implementations of this protocol (e.g., iOS Secure Enclave, Android StrongBox)
/// are responsible for securely generating and storing cryptographic keys,
/// as well as performing signing operations without ever exposing the private key
/// to the application memory space.
public protocol HardwareSecurityModule: Sendable {

  /// Generates a new hardware-backed keypair and returns the public key.
  ///
  /// The generated key must be a NIST P-256 (secp256r1) elliptic curve key.
  /// Any existing key for the application should be replaced or rotated.
  ///
  /// - Returns: The DER-encoded X.509 SubjectPublicKeyInfo representation of the public key.
  func generateKey() async throws -> Data

  /// Returns the public key of the existing hardware key, if one exists.
  ///
  /// - Returns: The DER-encoded X.509 SubjectPublicKeyInfo representation of the public key,
  ///            or `nil` if no key has been generated yet.
  func getPublicKey() async throws -> Data?

  /// Signs the provided payload using the hardware-backed private key.
  ///
  /// The data should be hashed using SHA-256 before signing, depending on the
  /// underlying platform APIs.
  ///
  /// - Parameter data: The raw data payload to be signed.
  /// - Returns: The DER-encoded ECDSA signature.
  func sign(_ data: Data) async throws -> Data

  /// Deletes the hardware-backed key from the secure storage.
  func deleteKey() async throws
}
