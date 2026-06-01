import Foundation
import Gateway
import HSM
import Storage

public final class SessionManager: @unchecked Sendable {
  private let storage: SecureStorage
  private let hsm: HardwareSecurityModule

  public init(storage: any SecureStorage, hsm: any HardwareSecurityModule) {
    self.storage = storage
    self.hsm = hsm
  }

  public func saveSession(response: OAuthCompleteResponse) throws {
    try saveString(response.accessToken, forKey: "access_token")
    try saveString(response.refreshToken, forKey: "refresh_token")
    try saveString(response.userId, forKey: "user_id")
    try saveString(response.jwt, forKey: "jwt")
    try saveString(response.salt, forKey: "salt")
  }

  public func logout() throws {
    try storage.clearAll()
    try hsm.deleteKey()
  }

  public func getAccessToken() throws -> String? {
    guard let item = try storage.get(forKey: "access_token") else { return nil }
    let bytes = item.value.map { UInt8($0) }
    return String(bytes: bytes, encoding: .utf8)
  }

  public func isLoggedIn() throws -> Bool {
    return try getAccessToken() != nil
  }

  private func saveString(_ value: String, forKey key: String) throws {
    let bytes = Array(value.utf8).map { Int8($0) }
    try storage.set(StorageItem(value: bytes), forKey: key)
  }
}
