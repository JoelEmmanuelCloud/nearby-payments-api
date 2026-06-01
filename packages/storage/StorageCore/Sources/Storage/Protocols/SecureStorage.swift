/// A simple key-value store protocol for small sensitive payloads.
public protocol SecureStorage: Sendable {
  /// Stores a byte value for the given key securely.
  func set(_ item: StorageItem, forKey key: String) throws

  /// Retrieves a securely stored byte value for the given key.
  func get(forKey key: String) throws -> StorageItem?

  /// Deletes the securely stored data for the given key.
  func delete(forKey key: String) throws

  /// Clears all securely stored data.
  func clearAll() throws
}
