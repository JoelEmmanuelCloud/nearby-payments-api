import CryptoKit
import Foundation
import Security

/// An implementation of `HardwareSecurityModule` backed by the Apple Secure Enclave.
///
/// This implementation generates and stores a NIST P-256 private key inside the
/// Secure Enclave. The private key cannot be extracted into application memory.
/// All cryptographic operations (signing) occur within the Secure Enclave itself.
public final class SecureEnclaveHSM: HardwareSecurityModule {

  /// The Keychain label used to uniquely identify this key.
  private let keyTag = "com.variance.nearby.hsm.key".data(using: .utf8)!

  public init() {}

  public func generateKey() throws -> DEREncodedItem {
    try deleteKey()

    let privateKey = try SecureEnclave.P256.Signing.PrivateKey()

    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: keyTag,
      kSecValueData as String: privateKey.dataRepresentation,
    ]

    let status = SecItemAdd(query as CFDictionary, nil)
    guard status == errSecSuccess else {
      throw HSMError.keyGenerationFailed(status: Int(status))
    }

    return DEREncodedItem(
      value: privateKey.publicKey.derRepresentation.map { Int8(bitPattern: $0) })
  }

  public func getPublicKey() throws -> DEREncodedItem? {
    guard let privateKey = try getPrivateKeyReference() else {
      return nil
    }
    return DEREncodedItem(
      value: privateKey.publicKey.derRepresentation.map { Int8(bitPattern: $0) })
  }

  private func signData(_ value: Data) throws -> Data {
    guard let privateKey = try getPrivateKeyReference() else {
      throw HSMError.keyNotFound
    }

    let digest = SHA256.hash(data: value)
    let signature = try privateKey.signature(for: digest)

    return signature.derRepresentation
  }

  public func sign(_ data: [Int8]) throws -> DEREncodedItem {
    let value = Data(data.map { UInt8(bitPattern: $0) })

    let sig = try signData(value)

    return DEREncodedItem(value: sig.map { Int8(bitPattern: $0) })
  }

  public func deleteKey() throws {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: keyTag,
    ]

    let status = SecItemDelete(query as CFDictionary)
    guard status == errSecSuccess || status == errSecItemNotFound else {
      throw HSMError.keyDeletionFailed(status: Int(status))
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
      throw HSMError.keyRetrievalFailed(status: Int(status))
    }

    return try SecureEnclave.P256.Signing.PrivateKey(dataRepresentation: data)
  }
}
