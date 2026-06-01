import Foundation
import Gateway
import HSM
import Storage

/// Manages the user session by securely storing and retrieving authentication tokens,
/// user identifiers, and cryptographic keys using the underlying hardware security module and secure storage.
public final class SessionManager: @unchecked Sendable {
  private let storage: SecureStorage
  private let hsm: HardwareSecurityModule

  /// Initializes a new instance of `SessionManager`.
  ///
  /// - Parameters:
  ///   - storage: The secure storage provider to persist tokens and session info.
  ///   - hsm: The hardware security module to manage device keys.
  public init(storage: any SecureStorage, hsm: any HardwareSecurityModule) {
    self.storage = storage
    self.hsm = hsm
  }

  /// Persists authentication and identity values from a successful sign-in response.
  ///
  /// - Parameter response: The OAuth completion response returned by the backend.
  /// - Throws: An error if storage persistence fails.
  public func saveSession(response: OAuthCompleteResponse) throws {
    try saveString(response.accessToken, forKey: "access_token")
    try saveString(response.refreshToken, forKey: "refresh_token")
    try saveString(response.userId, forKey: "user_id")
    try saveString(response.jwt, forKey: "jwt")
    try saveString(response.salt, forKey: "salt")
  }

  /// Clears the current user session by deleting all stored credentials
  /// and rotating/deleting HSM-backed cryptographic keys.
  ///
  /// - Throws: An error if storage clearance or HSM key deletion fails.
  public func logout() throws {
    try storage.clearAll()
    try hsm.deleteKey()
  }

  /// Retrieves the current active access token.
  ///
  /// - Returns: The access token string, or `nil` if no session is active.
  /// - Throws: An error if storage lookup fails.
  public func getAccessToken() throws -> String? {
    guard let item = try storage.get(forKey: "access_token") else { return nil }
    let bytes = item.value.map { UInt8($0) }
    return String(bytes: bytes, encoding: .utf8)
  }

  /// Checks if a user is currently logged in.
  ///
  /// - Returns: `true` if an active access token is present, otherwise `false`.
  /// - Throws: An error if storage lookup fails.
  public func isLoggedIn() throws -> Bool {
    return try getAccessToken() != nil
  }

  /// Helper to convert a string to bytes and write to secure storage.
  private func saveString(_ value: String, forKey key: String) throws {
    let bytes = Array(value.utf8).map { Int8($0) }
    try storage.set(StorageItem(value: bytes), forKey: key)
  }
}
