/// A simple key-value store protocol for small sensitive payloads.
///
/// Not `Sendable`: this is a Java-callback interface (a Kotlin class implements
/// it across the swift-java bridge). The swift-java convention is plain,
/// non-`Sendable` callback protocols — making it `Sendable` forces the generated
/// JNI wrapper to be `Sendable` while holding a non-`Sendable` Java handle. The
/// concrete conformer owns thread-safety; holders that need it (e.g.
/// `SessionManager`) assert it via `@unchecked Sendable`.
public protocol SecureStorage {
  /// Stores a byte value for the given key securely.
  func set(_ item: StorageItem, forKey key: String) throws

  /// Retrieves a securely stored byte value for the given key.
  func get(forKey key: String) throws -> StorageItem?

  /// Deletes the securely stored data for the given key.
  func delete(forKey key: String) throws

  /// Clears all securely stored data.
  func clearAll() throws
}
