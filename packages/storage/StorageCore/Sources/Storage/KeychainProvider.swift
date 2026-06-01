import Foundation
import Security

/// An iOS/macOS implementation of `SecureStorage` backed by the Keychain.
public final class KeychainProvider: SecureStorage {

  private let service: String

  /// Initializes a new `KeychainProvider`.
  ///
  /// - Parameter service: The keychain service identifier string. Defaults to "com.variance.nearby.storage".
  public init(service: String = "com.variance.nearby.storage") {
    self.service = service
  }

  /// Stores a `StorageItem` securely under the designated key using Keychain Services.
  /// If the item already exists, it is updated. Otherwise, a new record is added.
  ///
  /// - Parameters:
  ///   - item: The `StorageItem` containing the bytes to store.
  ///   - key: The key account identifier.
  /// - Throws: `StorageError` if item insertion or update fails.
  public func set(_ item: StorageItem, forKey key: String) throws {
    let data = Data(item.value.map { UInt8(bitPattern: $0) })

    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: key,
    ]

    let attributes: [String: Any] = [
      kSecValueData as String: data
    ]

    let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)

    if status == errSecItemNotFound {
      var newQuery = query
      newQuery[kSecValueData as String] = data
      let addStatus = SecItemAdd(newQuery as CFDictionary, nil)
      guard addStatus == errSecSuccess else {
        throw StorageError.unhandledError(status: Int(addStatus))
      }
    } else if status != errSecSuccess {
      throw StorageError.unhandledError(status: Int(status))
    }
  }

  /// Retrieves the stored `StorageItem` for the given key.
  ///
  /// - Parameter key: The key account identifier to search.
  /// - Returns: The stored `StorageItem` if found, or `nil` if the key does not exist.
  /// - Throws: `StorageError` if the lookup query fails.
  public func get(forKey key: String) throws -> StorageItem? {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: key,
      kSecReturnData as String: true,
      kSecMatchLimit as String: kSecMatchLimitOne,
    ]

    var item: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &item)

    if status == errSecItemNotFound {
      return nil
    }

    guard status == errSecSuccess else {
      throw StorageError.unhandledError(status: Int(status))
    }

    guard let data = item as? Data else {
      throw StorageError.unexpectedDataFormat
    }

    return StorageItem(value: data.map { Int8(bitPattern: $0) })
  }

  /// Deletes the keychain record associated with the given key.
  ///
  /// - Parameter key: The target key account identifier.
  /// - Throws: `StorageError` if deletion query fails.
  public func delete(forKey key: String) throws {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: key,
    ]

    let status = SecItemDelete(query as CFDictionary)
    guard status == errSecSuccess || status == errSecItemNotFound else {
      throw StorageError.unhandledError(status: Int(status))
    }
  }

  /// Clears all generic password items under the current service identifier.
  ///
  /// - Throws: `StorageError` if clear action fails.
  public func clearAll() throws {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
    ]

    let status = SecItemDelete(query as CFDictionary)
    guard status == errSecSuccess || status == errSecItemNotFound else {
      throw StorageError.unhandledError(status: Int(status))
    }
  }

  /// Convenience helper storing raw `Data` bytes under a key.
  ///
  /// - Parameters:
  ///   - value: The raw data bytes.
  ///   - key: The key account identifier.
  /// - Throws: `StorageError` if save fails.
  public func setData(_ value: Data, forKey key: String) throws {
    try set(StorageItem(value: value.map { Int8(bitPattern: $0) }), forKey: key)
  }

  /// Convenience helper retrieving stored raw `Data` bytes for a key.
  ///
  /// - Parameter key: The key account identifier.
  /// - Returns: The stored `Data` if found, or `nil`.
  /// - Throws: `StorageError` if lookup fails.
  public func getData(forKey key: String) throws -> Data? {
    guard let item = try get(forKey: key) else {
      return nil
    }

    return Data(item.value.map { UInt8(bitPattern: $0) })
  }
}
