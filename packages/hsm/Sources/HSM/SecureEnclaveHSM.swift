import CryptoKit
import Foundation
import Security

@testable import HSMShared

/// An implementation of `HardwareSecurityModule` backed by the Apple Secure Enclave.
///
/// This implementation generates and stores a NIST P-256 private key inside the
/// Secure Enclave. The private key cannot be extracted into application memory.
/// All cryptographic operations (signing) occur within the Secure Enclave itself.
public actor SecureEnclaveHSM: HardwareSecurityModule {

  /// The Keychain label used to uniquely identify this key.
  private let keyTag = "com.variance.nearby.hsm.key".data(using: .utf8)!

  public init() {}

  public func generateKey() async throws -> Data {
    try await deleteKey()

    let privateKey = try SecureEnclave.P256.Signing.PrivateKey()

    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: keyTag,
      kSecValueData as String: privateKey.dataRepresentation,
    ]

    let status = SecItemAdd(query as CFDictionary, nil)
    guard status == errSecSuccess else {
      throw HSMError.keyGenerationFailed(status)
    }

    return privateKey.publicKey.derRepresentation
  }

  public func getPublicKey() async throws -> Data? {
    guard let privateKey = try getPrivateKeyReference() else {
      return nil
    }
    return privateKey.publicKey.derRepresentation
  }

  public func sign(_ data: Data) async throws -> Data {
    guard let privateKey = try getPrivateKeyReference() else {
      throw HSMError.keyNotFound
    }

    let digest = SHA256.hash(data: data)
    let signature = try privateKey.signature(for: digest)
    return signature.derRepresentation
  }

  public func deleteKey() async throws {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: keyTag,
    ]

    let status = SecItemDelete(query as CFDictionary)
    guard status == errSecSuccess || status == errSecItemNotFound else {
      throw HSMError.keyDeletionFailed(status)
    }
  }

  // MARK: - Private Helpers

  private func getPrivateKeyReference() throws -> SecureEnclave.P256.Signing.PrivateKey? {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: keyTag,
      kSecReturnData as String: true,
      kSecMatchLimit as String: kSecMatchLimitOne,
    ]

    var item: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &item)

    if status == errSecItemNotFound {
      return nil
    }

    guard status == errSecSuccess, let data = item as? Data else {
      throw HSMError.keyRetrievalFailed(status)
    }

    return try SecureEnclave.P256.Signing.PrivateKey(dataRepresentation: data)
  }
}
