import Auth
import Gateway
import LeanSuiApi
import XCTest

@testable import Identity

// Helper to base64url encode for mock JWTs
extension [UInt8] {
  fileprivate func base64urlEncodedString() -> String {
    return Data(self).base64EncodedString()
      .replacingOccurrences(of: "+", with: "-")
      .replacingOccurrences(of: "/", with: "_")
      .replacingOccurrences(of: "=", with: "")
  }
}

// MARK: - Mock Services

final class MockAPIGateway: APIGatewayProtocol, @unchecked Sendable {
  var lastBoundAddress: String?
  var bindCount = 0
  var mockProfile: UserProfileResponse?
  var mockAvatarUrl: String = "https://mock.ipfs/avatar"
  var mockAvailability = true
  var mockTaskId = "task-123"
  var mockTaskStatus = "confirmed"
  var lastAccessToken: String?

  func serverPublicKey() async throws -> ServerPublicKeyResponse {
    return ServerPublicKeyResponse(publicKey: "mock-pub-key")
  }

  func beginOAuth(request: OAuthBeginRequest) async throws -> OAuthBeginResponse {
    return OAuthBeginResponse(authURL: "https://auth", state: "state")
  }

  func completeOAuth(request: OAuthCompleteRequest) async throws -> OAuthCompleteResponse {
    return OAuthCompleteResponse(
      accessToken: "access",
      refreshToken: "refresh",
      expiresAt: 99999,
      refreshExpiresAt: 99999,
      userId: "user123",
      suiAddress: "0x123",
      jwt: "mock-jwt",
      salt: "12345"
    )
  }

  func refresh(request: RefreshRequest, accessToken: String) async throws -> RefreshResponse {
    return RefreshResponse(
      accessToken: "new-access", refreshToken: "new-refresh", expiresAt: 9999,
      refreshExpiresAt: 9999)
  }

  func revoke(accessToken: String) async throws {}

  func assertIntegrity(
    request: IntegrityRequest, accessToken: String, deviceProvider: String, requestNonce: String,
    requestTimestamp: String
  ) async throws {}

  func issueCredential(
    request: CredentialRequest, accessToken: String, deviceProvider: String, requestNonce: String,
    requestTimestamp: String
  ) async throws -> DeviceCredential {
    throw NSError(domain: "Unimplemented", code: -1)
  }

  func bindWallet(request: BindWalletRequest, accessToken: String) async throws {
    self.lastBoundAddress = request.suiAddress
    self.lastAccessToken = accessToken
    self.bindCount += 1
  }

  func getProfile(accessToken: String) async throws -> UserProfileResponse {
    self.lastAccessToken = accessToken
    if let mockProfile { return mockProfile }
    return UserProfileResponse(
      userId: "user123", status: "active", avatarUrl: mockAvatarUrl, createdAt: 123456)
  }

  func uploadAvatar(data: [UInt8], contentType: String, accessToken: String) async throws
    -> AvatarUploadResponse
  {
    self.lastAccessToken = accessToken
    return AvatarUploadResponse(avatarUrl: mockAvatarUrl)
  }

  func uploadAvatar(data: Data, contentType: String, accessToken: String) async throws
    -> AvatarUploadResponse
  {
    self.lastAccessToken = accessToken
    return AvatarUploadResponse(avatarUrl: mockAvatarUrl)
  }

  func checkNameAvailability(leafName: String, accessToken: String) async throws
    -> NameAvailabilityResponse
  {
    self.lastAccessToken = accessToken
    return NameAvailabilityResponse(name: "\(leafName).nearby.sui", available: mockAvailability)
  }

  func registerLeafName(
    request: RegisterLeafRequest, accessToken: String, deviceProvider: String, requestNonce: String,
    requestTimestamp: String
  ) async throws -> RegisterLeafResponse {
    self.lastAccessToken = accessToken
    return RegisterLeafResponse(
      taskId: mockTaskId, nameHash: "hash", action: "register", status: "pending", expiresAt: 9999)
  }

  func getNameTask(
    taskId: String, accessToken: String, deviceProvider: String, requestNonce: String,
    requestTimestamp: String
  ) async throws -> NameTaskStatusResponse {
    self.lastAccessToken = accessToken
    return NameTaskStatusResponse(
      taskId: taskId, nameHash: "hash", action: "register", status: mockTaskStatus, createdAt: 100,
      updatedAt: 200, expiresAt: 300)
  }
}

final class MockSuiNSResolver: SuiNSResolverProtocol, @unchecked Sendable {
  var mockName: String? = "mockname.sui"
  var mockAddress: String? = "0x123"

  func resolveNameServiceNames(address: String) async throws -> String? {
    return mockName
  }

  func resolveNameServiceAddress(name: String) async throws -> String? {
    return mockAddress
  }
}

final class MockSessionTokenProvider: SessionTokenProvider, @unchecked Sendable {
  var mockAccessToken: String? = "mock-access-token"
  var mockSession: AuthSession?

  func getAccessToken() async throws -> String? {
    return mockAccessToken
  }

  func getCurrentSession() throws -> AuthSession? {
    return mockSession
  }
}

// MARK: - Tests

final class IdentityTests: XCTestCase {
  private var gateway: MockAPIGateway!
  private var resolver: MockSuiNSResolver!
  private var tokenProvider: MockSessionTokenProvider!
  private var manager: IdentityManager!

  override func setUp() {
    super.setUp()
    gateway = MockAPIGateway()
    resolver = MockSuiNSResolver()
    tokenProvider = MockSessionTokenProvider()
    manager = IdentityManager(
      gateway: gateway,
      nsResolver: resolver,
      tokenProvider: tokenProvider
    )
  }

  func testFetchProfile() async throws {
    let profile = try await manager.fetchProfile(suiAddress: "0x123")

    XCTAssertEqual(profile.userId, "user123")
    XCTAssertEqual(profile.suinsName, "mockname.sui")
    XCTAssertEqual(gateway.lastAccessToken, "mock-access-token")
  }

  func testBindWallet_explicitAddress() async throws {
    try await manager.bindWallet(suiAddress: "0x123")

    XCTAssertEqual(gateway.lastBoundAddress, "0x123")
    XCTAssertEqual(gateway.lastAccessToken, "mock-access-token")
  }

  func testRebind_bindsSessionAddress() async throws {
    tokenProvider.mockSession = AuthSession(
      accessToken: "mock-access-token",
      refreshToken: "mock-refresh-token",
      userId: "user123",
      jwt: "mock-jwt",
      salt: "10555",
      suiAddress: "0xabc",  // written by the login/zkLogin layer; identity only binds it
      accessExpiresAt: 99999,
      refreshExpiresAt: 99999,
      maxEpoch: 10,
      provider: .google
    )

    try await manager.rebind()

    XCTAssertEqual(gateway.bindCount, 1)
    XCTAssertEqual(gateway.lastBoundAddress, "0xabc")
  }

  func testRebind_noAddressIsNoOp() async throws {
    tokenProvider.mockSession = AuthSession(
      accessToken: "mock-access-token",
      refreshToken: "mock-refresh-token",
      userId: "user123",
      jwt: "mock-jwt",
      salt: "10555",
      suiAddress: nil,  // not yet derived
      accessExpiresAt: 99999,
      refreshExpiresAt: 99999,
      maxEpoch: 10,
      provider: .google
    )

    try await manager.rebind()

    XCTAssertEqual(gateway.bindCount, 0)
  }

  func testUpdateAvatarReturnsURL() async throws {
    tokenProvider.mockSession = AuthSession(
      accessToken: "mock-access-token",
      refreshToken: "mock-refresh-token",
      userId: "user123",
      jwt: "mock-jwt",
      salt: "salt",
      suiAddress: "0x12345",
      accessExpiresAt: 99999,
      refreshExpiresAt: 99999,
      maxEpoch: 10,
      provider: .google
    )

    gateway.mockAvatarUrl = "https://new.ipfs/new-avatar"
    let newUrl = try await manager.updateAvatar(data: [1, 2, 3], contentType: "image/png")
    XCTAssertEqual(newUrl, "https://new.ipfs/new-avatar")
  }
}
