import Foundation
import Gateway
import HSM
import Storage

/// Manages the user session by securely storing, refreshing, and revoking authentication state.
public final class SessionManager: @unchecked Sendable {
  private enum Key {
    static let accessToken = "access_token"
    static let refreshToken = "refresh_token"
    static let userId = "user_id"
    static let jwt = "jwt"
    static let salt = "salt"
    static let suiAddress = "sui_address"
    static let accessExpiresAt = "access_expires_at"
    static let refreshExpiresAt = "refresh_expires_at"
    static let maxEpoch = "max_epoch"
    static let provider = "provider"

    static let currentSessionKeys = [
      accessToken,
      refreshToken,
      userId,
      jwt,
      salt,
      suiAddress,
      accessExpiresAt,
      refreshExpiresAt,
      maxEpoch,
      provider,
    ]
  }

  private let storage: SecureStorage
  private let hsm: HardwareSecurityModule
  private let gateway: APIGatewayProtocol?

  /// Initializes a session manager without network refresh/revoke support.
  /// For situatuins where we need to make an operation without needing gateway call.
  init(storage: any SecureStorage, hsm: any HardwareSecurityModule) {
    self.storage = storage
    self.hsm = hsm
    self.gateway = nil
  }

  /// Initializes a session manager with backend refresh/revoke support.
  public init(
    storage: any SecureStorage,
    hsm: any HardwareSecurityModule,
    gateway: APIGateway
  ) {
    self.storage = storage
    self.hsm = hsm
    self.gateway = gateway
  }

  /// Initializes a session manager with a protocol gateway for Swift tests and non-bridged callers.
  init(
    storage: any SecureStorage,
    hsm: any HardwareSecurityModule,
    gateway: any APIGatewayProtocol
  ) {
    self.storage = storage
    self.hsm = hsm
    self.gateway = gateway
  }

  /// Persists authentication and identity values from a successful sign-in response.
  ///
  /// - Parameters:
  ///   - response: The successful complete OAuth response from the gateway.
  ///   - provider: The OAuth identity provider used for sign-in.
  ///   - maxEpoch: The blockchain epoch limit after which the zkLogin signature expires.
  /// - Throws: An error if storage persistence fails.
  public func saveSession(
    response: OAuthCompleteResponse, provider: OAuthProvider, maxEpoch: UInt64
  ) throws {
    let session = AuthSession(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
      userId: response.userId,
      jwt: response.jwt,
      salt: response.salt,
      suiAddress: response.suiAddress,
      accessExpiresAt: response.expiresAt,
      refreshExpiresAt: response.refreshExpiresAt,
      maxEpoch: maxEpoch,
      provider: provider
    )

    try saveSession(session)
  }

  /// Returns the currently stored session, or `nil` if no complete session is present.
  ///
  /// - Returns: The current `AuthSession` if present and fully populated, otherwise `nil`.
  /// - Throws: An error if secure storage retrieval fails.
  public func getCurrentSession() throws -> AuthSession? {
    guard
      let accessToken = try readString(forKey: Key.accessToken),
      let refreshToken = try readString(forKey: Key.refreshToken),
      let userId = try readString(forKey: Key.userId),
      let jwt = try readString(forKey: Key.jwt),
      let salt = try readString(forKey: Key.salt),
      let accessExpiresAt = try readInt64(forKey: Key.accessExpiresAt),
      let refreshExpiresAt = try readInt64(forKey: Key.refreshExpiresAt),
      let maxEpoch = try readUInt64(forKey: Key.maxEpoch),
      let providerString = try readString(forKey: Key.provider),
      let provider = OAuthProvider(rawValue: providerString)
    else {
      return nil
    }

    return AuthSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: userId,
      jwt: jwt,
      salt: salt,
      suiAddress: try readString(forKey: Key.suiAddress),
      accessExpiresAt: accessExpiresAt,
      refreshExpiresAt: refreshExpiresAt,
      maxEpoch: maxEpoch,
      provider: provider
    )
  }

  /// Checks whether the user has a session that has not crossed its refresh-token expiry gate.
  ///
  /// - Returns: `true` if a session is present and its refresh token is not expired, otherwise `false`.
  /// - Throws: An error if storage lookup fails.
  public func isLoggedIn() throws -> Bool {
    guard let session = try getCurrentSession() else {
      return false
    }

    return isSessionUsable(session)
  }

  /// Checks if the persisted zkLogin session is valid for the given epoch.
  ///
  /// - Parameter currentEpoch: The current epoch on the blockchain.
  /// - Returns: `true` if the current epoch is less than the session's maximum valid epoch (`maxEpoch`), otherwise `false`.
  /// - Throws: An error if secure storage retrieval fails.
  public func isZkLoginSessionUsable(currentEpoch: UInt64) throws -> Bool {
    guard let session = try getCurrentSession() else {
      return false
    }
    return currentEpoch < session.maxEpoch
  }

  /// Updates the Sui properties (max epoch and derived Sui address) in the current session.
  ///
  /// - Parameters:
  ///   - maxEpoch: The new maximum blockchain epoch limit.
  ///   - suiAddress: An optional new derived Sui address to update/bind.
  /// - Throws: `SessionError.sessionExpired` if no active session exists, or storage write error.
  public func updateSuiProperties(maxEpoch: UInt64, suiAddress: String? = nil) throws {
    guard let session = try getCurrentSession() else {
      throw SessionError.sessionExpired
    }
    let updated = AuthSession(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      userId: session.userId,
      jwt: session.jwt,
      salt: session.salt,
      suiAddress: suiAddress ?? session.suiAddress,
      accessExpiresAt: session.accessExpiresAt,
      refreshExpiresAt: session.refreshExpiresAt,
      maxEpoch: maxEpoch,
      provider: session.provider
    )
    try saveSession(updated)
  }

  /// Returns a valid access token, refreshing it when the stored access token is expired.
  ///
  /// - Returns: The active access token, or `nil` if no session is present.
  /// - Throws: `SessionError.sessionExpired` if the session is no longer usable, or other API/storage errors.
  public func getAccessToken() async throws -> String? {
    guard let session = try getCurrentSession() else {
      return nil
    }

    guard isSessionUsable(session) else {
      try clearSession(mode: .current)
      throw SessionError.sessionExpired
    }

    if session.accessExpiresAt > currentTimestamp() {
      return session.accessToken
    }

    return try await refreshSession(session).accessToken
  }

  /// Refreshes the access token and rotates the one-time refresh token.
  ///
  /// - Parameter currentSession: An optional already-loaded session. If nil, it will be loaded from storage.
  /// - Returns: The refreshed and persisted `AuthSession` instance.
  /// - Throws: `SessionError.sessionExpired` if the session is expired or invalid, or gateway errors.
  @discardableResult
  public func refreshSession(_ currentSession: AuthSession?) async throws -> AuthSession {
    guard let gateway else {
      throw SessionError.gatewayUnavailable
    }

    guard let session = try currentSession ?? getCurrentSession() else {
      throw SessionError.sessionExpired
    }

    guard isSessionUsable(session) else {
      try clearSession(mode: .current)
      throw SessionError.sessionExpired
    }

    do {
      let response = try await gateway.refresh(
        request: RefreshRequest(refreshToken: session.refreshToken),
        accessToken: session.accessToken
      )

      let refreshed = AuthSession(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        userId: session.userId,
        jwt: session.jwt,
        salt: session.salt,
        suiAddress: session.suiAddress,
        accessExpiresAt: response.expiresAt,
        refreshExpiresAt: response.refreshExpiresAt,
        maxEpoch: session.maxEpoch,
        provider: session.provider
      )

      try saveSession(refreshed)
      return refreshed
    } catch let error as GatewayError {
      if error.isTerminalSessionFailure {
        try clearSession(mode: .current)
      }
      throw error
    } catch {
      throw error
    }
  }

  /// Revokes the current backend session and always clears local session state.
  public func revokeSession() async throws {
    let session = try getCurrentSession()

    defer {
      do {
        try clearSession(mode: .current)
        try hsm.deleteKey()
      } catch {}
    }

    if let gateway, let session {
      do {
        try await gateway.revoke(accessToken: session.accessToken)
      } catch {
        throw SessionError.gatewayRevokeFailed
      }
    }
  }

  /// Clears either the current session or every secure value owned by the underlying providers.
  func clearSession(mode: SessionClearMode) throws {
    switch mode {
    case .current:
      for key in Key.currentSessionKeys {
        try storage.delete(forKey: key)
      }
    case .all:
      try storage.clearAll()
      try hsm.deleteKey()
    }
  }

  /// Persists all components of an authentication session to secure storage.
  private func saveSession(_ session: AuthSession) throws {
    try saveString(session.accessToken, forKey: Key.accessToken)
    try saveString(session.refreshToken, forKey: Key.refreshToken)
    try saveString(session.userId, forKey: Key.userId)
    try saveString(session.jwt, forKey: Key.jwt)
    try saveString(session.salt, forKey: Key.salt)
    try saveString(session.suiAddress, forKey: Key.suiAddress)
    try saveString(String(session.accessExpiresAt), forKey: Key.accessExpiresAt)
    try saveString(String(session.refreshExpiresAt), forKey: Key.refreshExpiresAt)
    try saveString(String(session.maxEpoch), forKey: Key.maxEpoch)
    try saveString(session.provider.rawValue, forKey: Key.provider)
  }

  /// Evaluates if a session is valid based on its refresh expiration.
  private func isSessionUsable(_ session: AuthSession) -> Bool {
    return session.refreshExpiresAt > currentTimestamp()
  }

  /// Returns the current Unix timestamp in seconds.
  private func currentTimestamp() -> Int64 {
    Int64(Date().timeIntervalSince1970)
  }

  /// Saves an optional string to secure storage, deleting the key if the value is nil or empty.
  private func saveString(_ value: String?, forKey key: String) throws {
    guard let value, !value.isEmpty else {
      try storage.delete(forKey: key)
      return
    }

    try saveString(value, forKey: key)
  }

  /// Encodes and saves a string to secure storage as a byte array.
  private func saveString(_ value: String, forKey key: String) throws {
    let bytes = Array(value.utf8).map { Int8(bitPattern: $0) }
    try storage.set(StorageItem(value: bytes), forKey: key)
  }

  /// Reads and decodes a UTF-8 string from secure storage for the given key.
  private func readString(forKey key: String) throws -> String? {
    guard let item = try storage.get(forKey: key) else {
      return nil
    }

    let bytes = item.value.map { UInt8(bitPattern: $0) }
    return String(bytes: bytes, encoding: .utf8)
  }

  /// Reads a string from secure storage and converts it to an Int64.
  private func readInt64(forKey key: String) throws -> Int64? {
    guard let value = try readString(forKey: key) else {
      return nil
    }

    return Int64(value)
  }

  /// Reads a string from secure storage and converts it to a UInt64.
  private func readUInt64(forKey key: String) throws -> UInt64? {
    guard let value = try readString(forKey: key) else {
      return nil
    }

    return UInt64(value)
  }
}
