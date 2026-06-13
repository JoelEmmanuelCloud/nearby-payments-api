import Foundation
import Testing

@testable import Gateway

@Suite("API Gateway")
struct APIGatewayTests {

  @Test("serverPublicKey sends GET to the correct path")
  func serverPublicKey() async throws {
    let expected = ServerPublicKeyResponse(publicKey: "ed25519-pub-key-hex")
    let mock = MockHTTPClient(
      responseBody: try JSONCoders.encoder.encode(expected),
      statusCode: 200
    )
    let gateway = APIGateway(configuration: .test, httpClient: mock)

    let result = try await gateway.serverPublicKey()

    #expect(result == expected)
    #expect(mock.capturedRequest?.httpMethod == "GET")
    #expect(mock.capturedRequest?.url?.path.contains("server-public-key") == true)
    #expect(mock.capturedRequest?.value(forHTTPHeaderField: "Authorization") == nil)
  }

  @Test("beginOAuth sends correct payload and parses response")
  func beginOAuth() async throws {
    let expectedResponse = OAuthBeginResponse(
      authURL: "https://accounts.google.com/o/oauth2/v2/auth?client_id=test",
      state: "csrf-state-abc"
    )
    let mock = MockHTTPClient(
      responseBody: try JSONCoders.encoder.encode(expectedResponse),
      statusCode: 200
    )
    let gateway = APIGateway(configuration: .test, httpClient: mock)

    let request = OAuthBeginRequest(
      flowType: .web,
      provider: .google,
      codeChallenge: "E9Melhoa2OwvFrEMTJguCHaoeK1t8URWbuGJSstw-cM",
      codeChallengeMethod: "S256",
      zkLoginNonce: "zklogin-nonce-123"
    )
    let result = try await gateway.beginOAuth(request: request)

    #expect(result == expectedResponse)
    #expect(mock.capturedRequest?.httpMethod == "POST")
    #expect(mock.capturedRequest?.url?.path.contains("oauth/begin") == true)

    let sentBody = try JSONCoders.decoder.decode(
      OAuthBeginRequest.self,
      from: mock.capturedRequest!.httpBody!
    )
    #expect(sentBody.provider == .google)
    #expect(sentBody.codeChallengeMethod == "S256")
    #expect(sentBody.zkLoginNonce == "zklogin-nonce-123")
  }

  @Test("beginOAuth parses native response without auth URL")
  func beginOAuthNative() async throws {
    let expectedResponse = OAuthBeginResponse(state: "native-state")
    let mock = MockHTTPClient(
      responseBody: try JSONCoders.encoder.encode(expectedResponse),
      statusCode: 200
    )
    let gateway = APIGateway(configuration: .test, httpClient: mock)

    let result = try await gateway.beginOAuth(
      request: OAuthBeginRequest(
        flowType: .native,
        provider: .apple,
        zkLoginNonce: "native-nonce"
      )
    )

    #expect(result == expectedResponse)
    #expect(result.authURL == nil)
  }

  @Test("completeOAuth sends device metadata and returns session tokens")
  func completeOAuth() async throws {
    let expectedResponse = OAuthCompleteResponse(
      accessToken: "access-jwt",
      refreshToken: "refresh-jwt",
      expiresAt: 1_700_000_900,
      refreshExpiresAt: 1_702_592_000,
      userId: "user-123",
      suiAddress: "0x0000000000000000000000000000000000000000000000000000000000000001",
      jwt: "provider-jwt",
      salt: "user-salt"
    )
    let mock = MockHTTPClient(
      responseBody: try JSONCoders.encoder.encode(expectedResponse),
      statusCode: 200
    )
    let gateway = APIGateway(configuration: .test, httpClient: mock)

    let request = OAuthCompleteRequest(
      platform: "ios",
      osVersion: "18.0",
      appBundleId: "com.nearby.test",
      deviceIntegrity: .stub,
      payload: .web(
        code: "google-auth-code",
        state: "csrf-state-abc",
        codeVerifier: "dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk"
      )
    )
    let result = try await gateway.completeOAuth(request: request)

    #expect(result == expectedResponse)
    #expect(result.userId == "user-123")
    #expect(result.expiresAt == 1_700_000_900)
    #expect(result.refreshExpiresAt == 1_702_592_000)
    #expect(
      result.suiAddress == "0x0000000000000000000000000000000000000000000000000000000000000001")

    let json =
      try JSONSerialization.jsonObject(with: mock.capturedRequest!.httpBody!) as? [String: Any]
    #expect(json?["platform"] as? String == "ios")
    #expect(json?["flowType"] as? String == "web")
    #expect((json?["deviceIntegrity"] as? [String: Any])?["provider"] as? String == "stub")
  }

  @Test("refresh sends bearer token and returns rotated tokens")
  func refresh() async throws {
    let expectedResponse = RefreshResponse(
      accessToken: "new-access",
      refreshToken: "new-refresh",
      expiresAt: 1_700_000_900,
      refreshExpiresAt: 1_702_592_000
    )
    let mock = MockHTTPClient(
      responseBody: try JSONCoders.encoder.encode(expectedResponse),
      statusCode: 200
    )
    let gateway = APIGateway(configuration: .test, httpClient: mock)

    let result = try await gateway.refresh(
      request: RefreshRequest(refreshToken: "old-refresh"),
      accessToken: "current-access"
    )

    #expect(result == expectedResponse)
    #expect(
      mock.capturedRequest?.value(forHTTPHeaderField: "Authorization")
        == "Bearer current-access"
    )
  }

  @Test("revoke sends bearer token with no body")
  func revoke() async throws {
    let mock = MockHTTPClient(statusCode: 200)
    let gateway = APIGateway(configuration: .test, httpClient: mock)

    try await gateway.revoke(accessToken: "token-to-revoke")

    #expect(mock.capturedRequest?.httpMethod == "POST")
    #expect(mock.capturedRequest?.url?.path.contains("revoke") == true)
    #expect(
      mock.capturedRequest?.value(forHTTPHeaderField: "Authorization")
        == "Bearer token-to-revoke"
    )
  }

  @Test("assertIntegrity injects device headers alongside bearer token")
  func assertIntegrity() async throws {
    let mock = MockHTTPClient(statusCode: 200)
    let gateway = APIGateway(configuration: .test, httpClient: mock)

    try await gateway.assertIntegrity(
      request: IntegrityRequest(
        deviceIntegrity: .stub,
        timestampMs: 1_700_000_000_000
      ),
      accessToken: "access-token",
      deviceProvider: "appleAppAttest",
      requestNonce: "random-nonce-hex",
      requestTimestamp: "1700000000000"
    )

    let req = mock.capturedRequest!
    #expect(req.value(forHTTPHeaderField: "Authorization") == "Bearer access-token")
    #expect(req.value(forHTTPHeaderField: "X-Device-Provider") == "appleAppAttest")
    #expect(req.value(forHTTPHeaderField: "X-Request-Nonce") == "random-nonce-hex")
    #expect(req.value(forHTTPHeaderField: "X-Request-Timestamp") == "1700000000000")
  }

  @Test("issueCredential sends public key with device headers and returns signed credential")
  func issueCredential() async throws {
    let expected = DeviceCredential(
      version: 1,
      userId: "user-123",
      platform: "ios",
      appBundleId: "com.variance.nearby",
      integrityProvider: "stub",
      localProofPublicKey: "0xpubkey",
      suiAddress: "0x0000000000000000000000000000000000000000000000000000000000000001",
      suinsName: "",
      capabilities: DeviceCredentialCapabilities(nearbyPayments: true, nearbyAssist: false),
      issuedAt: 1_700_000_000,
      expiresAt: 1_700_086_400,
      issuer: "nearby-payments-api",
      signature: "base64url-sig"
    )
    let mock = MockHTTPClient(
      responseBody: try JSONCoders.encoder.encode(expected),
      statusCode: 200
    )
    let gateway = APIGateway(configuration: .test, httpClient: mock)

    let credential = try await gateway.issueCredential(
      request: CredentialRequest(localProofPublicKey: "0xpubkey"),
      accessToken: "access-token",
      deviceProvider: "stub",
      requestNonce: "nonce",
      requestTimestamp: "12345"
    )

    #expect(credential == expected)
    #expect(credential.signature == "base64url-sig")
    let sentBody = try JSONCoders.decoder.decode(
      CredentialRequest.self,
      from: mock.capturedRequest!.httpBody!
    )
    #expect(sentBody.localProofPublicKey == "0xpubkey")
    #expect(mock.capturedRequest?.value(forHTTPHeaderField: "X-Device-Provider") == "stub")
  }

  @Test("server error is surfaced with status code and body")
  func serverErrorHandling() async throws {
    let errorBody = #"{"error":"invalid_code","message":"Authorization code expired"}"#
    let mock = MockHTTPClient(
      responseBody: errorBody.data(using: .utf8)!,
      statusCode: 401
    )
    let gateway = APIGateway(configuration: .test, httpClient: mock)

    await #expect(throws: GatewayError.self) {
      _ = try await gateway.beginOAuth(
        request: OAuthBeginRequest(
          flowType: .web,
          provider: .google,
          codeChallenge: "challenge",
          codeChallengeMethod: "S256",
          zkLoginNonce: "nonce"
        )
      )
    }
  }

  @Test("network failure is wrapped into GatewayError.networkFailure")
  func networkFailureHandling() async throws {
    let mock = MockHTTPClient(
      errorToThrow: URLError(.notConnectedToInternet)
    )
    let gateway = APIGateway(configuration: .test, httpClient: mock)

    await #expect(throws: GatewayError.self) {
      _ = try await gateway.serverPublicKey()
    }
  }

  @Test("decoding failure is wrapped into GatewayError.decodingFailed")
  func decodingFailureHandling() async throws {
    let mock = MockHTTPClient(
      responseBody: #"{"unexpected":"shape"}"#.data(using: .utf8)!,
      statusCode: 200
    )
    let gateway = APIGateway(configuration: .test, httpClient: mock)

    await #expect(throws: GatewayError.self) {
      _ = try await gateway.serverPublicKey()
    }
  }

  @Test("requests target the correct versioned path")
  func urlConstruction() async throws {
    let expected = OAuthBeginResponse(authURL: "https://test.com", state: "s")
    let mock = MockHTTPClient(
      responseBody: try JSONCoders.encoder.encode(expected),
      statusCode: 200
    )
    let gateway = APIGateway(configuration: .test, httpClient: mock)

    _ = try await gateway.beginOAuth(
      request: OAuthBeginRequest(
        flowType: .web,
        provider: .google,
        codeChallenge: "c",
        codeChallengeMethod: "S256",
        zkLoginNonce: "n"
      )
    )

    let url = mock.capturedRequest!.url!
    #expect(url.absoluteString == "http://localhost:8080/v1/auth/oauth/begin")
  }

  @Test("bindWallet sends PUT to correct path with JSON body")
  func bindWallet() async throws {
    let mock = MockHTTPClient(statusCode: 204)
    let gateway = APIGateway(configuration: .test, httpClient: mock)

    let request = BindWalletRequest(suiAddress: "0x123456789")
    try await gateway.bindWallet(request: request, accessToken: "test-token")

    let req = mock.capturedRequest!
    #expect(req.httpMethod == "PUT")
    #expect(req.url?.path.contains("me/wallet") == true)
    #expect(req.value(forHTTPHeaderField: "Authorization") == "Bearer test-token")
    #expect(req.value(forHTTPHeaderField: "Content-Type") == "application/json")

    let sentBody = try JSONCoders.decoder.decode(
      BindWalletRequest.self,
      from: req.httpBody!
    )
    #expect(sentBody.suiAddress == "0x123456789")
  }

  @Test("getProfile sends GET and returns user profile metadata")
  func getProfile() async throws {
    let expected = UserProfileResponse(
      userId: "user-abc",
      status: "active",
      avatarUrl: "https://blobs/123",
      createdAt: 1_700_000_000
    )
    let mock = MockHTTPClient(
      responseBody: try JSONCoders.encoder.encode(expected),
      statusCode: 200
    )
    let gateway = APIGateway(configuration: .test, httpClient: mock)

    let result = try await gateway.getProfile(accessToken: "test-token")

    #expect(result == expected)
    let req = mock.capturedRequest!
    #expect(req.httpMethod == "GET")
    #expect(req.url?.path.contains("me/profile") == true)
    #expect(req.value(forHTTPHeaderField: "Authorization") == "Bearer test-token")
  }

  @Test("uploadAvatar sends PUT with raw image data and custom content-type")
  func uploadAvatar() async throws {
    let expected = AvatarUploadResponse(avatarUrl: "https://blobs/456")
    let mock = MockHTTPClient(
      responseBody: try JSONCoders.encoder.encode(expected),
      statusCode: 200
    )
    let gateway = APIGateway(configuration: .test, httpClient: mock)

    let imageData = "fake-jpeg-data".data(using: .utf8)!
    let result = try await gateway.uploadAvatar(
      data: imageData,
      contentType: "image/jpeg",
      accessToken: "test-token"
    )

    #expect(result == expected)
    let req = mock.capturedRequest!
    #expect(req.httpMethod == "PUT")
    #expect(req.url?.path.contains("me/avatar") == true)
    #expect(req.value(forHTTPHeaderField: "Authorization") == "Bearer test-token")
    #expect(req.value(forHTTPHeaderField: "Content-Type") == "image/jpeg")
    #expect(req.httpBody == imageData)
  }

  @Test("checkNameAvailability sends GET to correct path")
  func checkNameAvailability() async throws {
    let expected = NameAvailabilityResponse(name: "alice.nearby", available: true)
    let mock = MockHTTPClient(
      responseBody: try JSONCoders.encoder.encode(expected),
      statusCode: 200
    )
    let gateway = APIGateway(configuration: .test, httpClient: mock)

    let result = try await gateway.checkNameAvailability(
      leafName: "alice", accessToken: "test-token")

    #expect(result == expected)
    let req = mock.capturedRequest!
    #expect(req.httpMethod == "GET")
    #expect(req.url?.path.contains("names/leaf/alice/available") == true)
    #expect(req.value(forHTTPHeaderField: "Authorization") == "Bearer test-token")
  }

  @Test("registerLeafName sends POST with device headers and returns task info")
  func registerLeafName() async throws {
    let expected = RegisterLeafResponse(
      taskId: "task-99",
      nameHash: "hash123",
      action: "register",
      status: "pending",
      expiresAt: 1_700_003_600
    )
    let mock = MockHTTPClient(
      responseBody: try JSONCoders.encoder.encode(expected),
      statusCode: 202
    )
    let gateway = APIGateway(configuration: .test, httpClient: mock)

    let request = RegisterLeafRequest(leafName: "alice")
    let result = try await gateway.registerLeafName(
      request: request,
      accessToken: "test-token",
      deviceProvider: "apple_dcapp_attest",
      requestNonce: "nonce123",
      requestTimestamp: "timestamp456"
    )

    #expect(result == expected)
    let req = mock.capturedRequest!
    #expect(req.httpMethod == "POST")
    #expect(req.url?.path.contains("names/leaf") == true)
    #expect(req.value(forHTTPHeaderField: "Authorization") == "Bearer test-token")
    #expect(req.value(forHTTPHeaderField: "X-Device-Provider") == "apple_dcapp_attest")
    #expect(req.value(forHTTPHeaderField: "X-Request-Nonce") == "nonce123")
    #expect(req.value(forHTTPHeaderField: "X-Request-Timestamp") == "timestamp456")

    let sentBody = try JSONCoders.decoder.decode(
      RegisterLeafRequest.self,
      from: req.httpBody!
    )
    #expect(sentBody.leafName == "alice")
  }

  @Test("getNameTask sends GET with device headers to correct path")
  func getNameTask() async throws {
    let expected = NameTaskStatusResponse(
      taskId: "task-99",
      nameHash: "hash123",
      action: "register",
      status: "confirmed",
      createdAt: 1_700_000_000,
      updatedAt: 1_700_000_100,
      expiresAt: 1_700_003_600
    )
    let mock = MockHTTPClient(
      responseBody: try JSONCoders.encoder.encode(expected),
      statusCode: 200
    )
    let gateway = APIGateway(configuration: .test, httpClient: mock)

    let result = try await gateway.getNameTask(
      taskId: "task-99",
      accessToken: "test-token",
      deviceProvider: "apple_dcapp_attest",
      requestNonce: "nonce123",
      requestTimestamp: "timestamp456"
    )

    #expect(result == expected)
    let req = mock.capturedRequest!
    #expect(req.httpMethod == "GET")
    #expect(req.url?.path.contains("names/tasks/task-99") == true)
    #expect(req.value(forHTTPHeaderField: "Authorization") == "Bearer test-token")
    #expect(req.value(forHTTPHeaderField: "X-Device-Provider") == "apple_dcapp_attest")
    #expect(req.value(forHTTPHeaderField: "X-Request-Nonce") == "nonce123")
    #expect(req.value(forHTTPHeaderField: "X-Request-Timestamp") == "timestamp456")
  }
}
