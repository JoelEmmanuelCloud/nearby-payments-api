import Foundation
import Gateway
import HSM
import Storage
import Testing

@testable import Auth

@Suite("Session Manager")
struct SessionManagerTests {
  @Test("save and read full session")
  func saveAndReadCurrentSession() throws {
    let storage = MockStorage()
    let manager = SessionManager(storage: storage, hsm: MockHSM())
    let response = makeOAuthCompleteResponse()

    try manager.saveSession(response: response, provider: .google, maxEpoch: 42)

    let session = try #require(try manager.getCurrentSession())
    #expect(session.accessToken == "access-token")
    #expect(session.refreshToken == "refresh-token")
    #expect(session.userId == "user-123")
    #expect(session.suiAddress == "0xabc")
    #expect(session.accessExpiresAt == response.expiresAt)
    #expect(session.refreshExpiresAt == response.refreshExpiresAt)
    #expect(session.maxEpoch == 42)
    #expect(session.provider == .google)
  }

  @Test("getAccessToken returns cached valid token")
  func getAccessTokenReturnsCachedToken() async throws {
    let gateway = MockGateway()
    let manager = SessionManager(storage: MockStorage(), hsm: MockHSM(), gateway: gateway)

    try manager.saveSession(
      response: makeOAuthCompleteResponse(accessExpiresAt: now() + 900),
      provider: .google,
      maxEpoch: 5
    )

    let token = try await manager.getAccessToken()

    #expect(token == "access-token")
    #expect(gateway.refreshCallCount == 0)
  }

  @Test("getAccessToken refreshes access and refresh token")
  func getAccessTokenRefreshesAccessAndRefreshToken() async throws {
    let gateway = MockGateway(
      refreshResponse: RefreshResponse(
        accessToken: "new-access",
        refreshToken: "new-refresh",
        expiresAt: now() + 900,
        refreshExpiresAt: now() + 1_800
      )
    )
    let manager = SessionManager(storage: MockStorage(), hsm: MockHSM(), gateway: gateway)
    let originalRefreshExpiry = now() + 2_592_000

    try manager.saveSession(
      response: makeOAuthCompleteResponse(
        accessExpiresAt: now() - 1,
        refreshExpiresAt: originalRefreshExpiry
      ),
      provider: .google,
      maxEpoch: 5
    )

    let token = try await manager.getAccessToken()
    let session = try #require(try manager.getCurrentSession())

    #expect(token == "new-access")
    #expect(session.accessToken == "new-access")
    #expect(session.refreshToken == "new-refresh")
    #expect(session.accessExpiresAt == gateway.refreshResponse.expiresAt)
    #expect(session.refreshExpiresAt == gateway.refreshResponse.refreshExpiresAt)
    #expect(gateway.refreshCallCount == 1)
  }

  @Test("session expires at refresh expiry")
  func sessionExpiresAtRefreshExpiry() async throws {
    let manager = SessionManager(storage: MockStorage(), hsm: MockHSM(), gateway: MockGateway())

    try manager.saveSession(
      response: makeOAuthCompleteResponse(refreshExpiresAt: now() - 1),
      provider: .google,
      maxEpoch: 5
    )

    await #expect(throws: SessionError.sessionExpired) {
      _ = try await manager.getAccessToken()
    }

    #expect(try manager.getCurrentSession() == nil)
  }

  @Test("session expires at max epoch")
  func sessionExpiresAtMaxEpoch() async throws {
    let manager = SessionManager(storage: MockStorage(), hsm: MockHSM(), gateway: MockGateway())

    try manager.saveSession(response: makeOAuthCompleteResponse(), provider: .google, maxEpoch: 5)

    #expect(try manager.isZkLoginSessionUsable(currentEpoch: 4) == true)
    #expect(try manager.isZkLoginSessionUsable(currentEpoch: 5) == false)
    #expect(try manager.getCurrentSession() != nil)
  }

  @Test("update Sui properties updates stored value")
  func updateSuiPropertiesUpdatesStoredValue() async throws {
    let manager = SessionManager(storage: MockStorage(), hsm: MockHSM(), gateway: MockGateway())

    try manager.saveSession(response: makeOAuthCompleteResponse(), provider: .google, maxEpoch: 5)

    try manager.updateSuiProperties(maxEpoch: 10, suiAddress: "new-sui-address")

    let session = try #require(try manager.getCurrentSession())
    #expect(session.maxEpoch == 10)
    #expect(session.suiAddress == "new-sui-address")
    #expect(try manager.isZkLoginSessionUsable(currentEpoch: 9) == true)
    #expect(try manager.isZkLoginSessionUsable(currentEpoch: 10) == false)
  }

  @Test("network refresh failure keeps session")
  func networkRefreshFailureKeepsSession() async throws {
    let gateway = MockGateway(refreshError: GatewayError.networkFailure(description: "offline"))
    let manager = SessionManager(storage: MockStorage(), hsm: MockHSM(), gateway: gateway)

    try manager.saveSession(
      response: makeOAuthCompleteResponse(accessExpiresAt: now() - 1),
      provider: .google,
      maxEpoch: 5
    )

    await #expect(throws: GatewayError.self) {
      _ = try await manager.getAccessToken()
    }

    #expect(try manager.getCurrentSession() != nil)
  }

  @Test("terminal refresh failure clears session")
  func terminalRefreshFailureClearsSession() async throws {
    let gateway = MockGateway(
      refreshError: GatewayError.serverError(statusCode: 401, body: "invalid"))
    let manager = SessionManager(storage: MockStorage(), hsm: MockHSM(), gateway: gateway)

    try manager.saveSession(
      response: makeOAuthCompleteResponse(accessExpiresAt: now() - 1),
      provider: .google,
      maxEpoch: 5
    )

    await #expect(throws: GatewayError.self) {
      _ = try await manager.getAccessToken()
    }

    #expect(try manager.getCurrentSession() == nil)
  }

  @Test("revoke clears local session even when backend fails")
  func revokeClearsLocalSessionEvenWhenBackendFails() async throws {
    let hsm = MockHSM()
    let gateway = MockGateway(revokeError: GatewayError.networkFailure(description: "offline"))
    let manager = SessionManager(storage: MockStorage(), hsm: hsm, gateway: gateway)

    try manager.saveSession(response: makeOAuthCompleteResponse(), provider: .google, maxEpoch: 5)

    await #expect(throws: SessionError.gatewayRevokeFailed) {
      try await manager.revokeSession()
    }

    #expect(try manager.getCurrentSession() == nil)
    #expect(hsm.didDeleteKey)
  }
}

private func now() -> Int64 {
  Int64(Date().timeIntervalSince1970)
}

private func makeOAuthCompleteResponse(
  accessExpiresAt: Int64 = now() + 900,
  refreshExpiresAt: Int64 = now() + 2_592_000
) -> OAuthCompleteResponse {
  OAuthCompleteResponse(
    accessToken: "access-token",
    refreshToken: "refresh-token",
    expiresAt: accessExpiresAt,
    refreshExpiresAt: refreshExpiresAt,
    userId: "user-123",
    suiAddress: "0xabc",
    jwt: "provider-jwt",
    salt: "salt"
  )
}

private final class MockStorage: SecureStorage, @unchecked Sendable {
  private var values: [String: StorageItem] = [:]

  func set(_ item: StorageItem, forKey key: String) throws {
    values[key] = item
  }

  func get(forKey key: String) throws -> StorageItem? {
    values[key]
  }

  func delete(forKey key: String) throws {
    values.removeValue(forKey: key)
  }

  func clearAll() throws {
    values.removeAll()
  }
}

private final class MockHSM: HardwareSecurityModule, @unchecked Sendable {
  private(set) var didDeleteKey = false

  func generateKey() throws -> DEREncodedItem {
    DEREncodedItem(value: [])
  }

  func getPublicKey() throws -> DEREncodedItem? {
    nil
  }

  func sign(_ data: [Int8]) throws -> DEREncodedItem {
    DEREncodedItem(value: data)
  }

  func deleteKey() throws {
    didDeleteKey = true
  }
}

private final class MockGateway: APIGatewayProtocol, @unchecked Sendable {
  let refreshResponse: RefreshResponse
  let refreshError: Error?
  let revokeError: Error?
  private(set) var refreshCallCount = 0

  init(
    refreshResponse: RefreshResponse = RefreshResponse(
      accessToken: "refreshed-access",
      refreshToken: "refreshed-refresh",
      expiresAt: now() + 900,
      refreshExpiresAt: now() + 2_592_000
    ),
    refreshError: Error? = nil,
    revokeError: Error? = nil
  ) {
    self.refreshResponse = refreshResponse
    self.refreshError = refreshError
    self.revokeError = revokeError
  }

  func serverPublicKey() async throws -> ServerPublicKeyResponse {
    ServerPublicKeyResponse(publicKey: "key")
  }

  func beginOAuth(request: OAuthBeginRequest) async throws -> OAuthBeginResponse {
    OAuthBeginResponse(state: "state")
  }

  func completeOAuth(request: OAuthCompleteRequest) async throws -> OAuthCompleteResponse {
    makeOAuthCompleteResponse()
  }

  func refresh(request: RefreshRequest, accessToken: String) async throws -> RefreshResponse {
    refreshCallCount += 1

    if let refreshError {
      throw refreshError
    }

    return refreshResponse
  }

  func revoke(accessToken: String) async throws {
    if let revokeError {
      throw revokeError
    }
  }

  func assertIntegrity(
    request: IntegrityRequest,
    accessToken: String,
    deviceProvider: String,
    requestNonce: String,
    requestTimestamp: String
  ) async throws {
  }

  func issueCredential(
    request: CredentialRequest,
    accessToken: String,
    deviceProvider: String,
    requestNonce: String,
    requestTimestamp: String
  ) async throws -> DeviceCredential {
    throw AuthError.unknown
  }
}
