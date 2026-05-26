import Foundation

/// A simple, asynchronous Key-Value store protocol for sensitive data.
public protocol SecureStorage: Sendable {
  /// Stores a data value for the given key securely.
  func set(_ value: Data, forKey key: String) async throws

  /// Retrieves a securely stored data value for the given key.
  func get(forKey key: String) async throws -> Data?

  /// Deletes the securely stored data for the given key.
  func delete(forKey key: String) async throws

  /// Clears all securely stored data.
  func clearAll() async throws
}
