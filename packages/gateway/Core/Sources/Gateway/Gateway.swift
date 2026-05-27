import Foundation

public final class APIGateway: AuthGateway {

  private let executor: HTTPRequestExecutor

  public init(
    configuration: GatewayConfiguration,
    httpClient: HTTPClient
  ) {
    self.executor = HTTPRequestExecutor(
      configuration: configuration,
      httpClient: httpClient
    )
  }

  public convenience init(baseURLString: String, apiVersion: String) throws {
    guard let baseURL = URL(string: baseURLString) else {
      throw GatewayError.invalidURL(path: baseURLString)
    }

    self.init(
      configuration: GatewayConfiguration(baseURL: baseURL, apiVersion: apiVersion),
      httpClient: URLSessionHTTPClient()
    )
  }

  public func serverPublicKey() async throws -> ServerPublicKeyResponse {
    try await executor.get(path: APIConstants.Auth.serverPublicKey)
  }

  public func beginOAuth(request: OAuthBeginRequest) async throws -> OAuthBeginResponse {
    try await executor.post(path: APIConstants.Auth.oauthBegin, body: request)
  }

  public func completeOAuth(request: OAuthCompleteRequest) async throws -> OAuthCompleteResponse {
    try await executor.post(path: APIConstants.Auth.oauthComplete, body: request)
  }

  public func refresh(
    request: RefreshRequest,
    accessToken: String
  ) async throws -> RefreshResponse {
    try await executor.post(
      path: APIConstants.Auth.refresh,
      body: request,
      accessToken: accessToken
    )
  }

  public func revoke(accessToken: String) async throws {
    try await executor.postVoid(
      path: APIConstants.Auth.revoke,
      accessToken: accessToken
    )
  }

  public func assertIntegrity(
    request: IntegrityRequest,
    accessToken: String,
    deviceProvider: String,
    requestNonce: String,
    requestTimestamp: String
  ) async throws {
    try await executor.postVoid(
      path: APIConstants.Auth.integrity,
      body: request,
      accessToken: accessToken,
      deviceHeaders: DeviceHeaders(
        provider: deviceProvider,
        nonce: requestNonce,
        timestamp: requestTimestamp
      )
    )
  }

  public func issueCredential(
    request: CredentialRequest,
    accessToken: String,
    deviceProvider: String,
    requestNonce: String,
    requestTimestamp: String
  ) async throws -> DeviceCredential {
    try await executor.post(
      path: APIConstants.Auth.credential,
      body: request,
      accessToken: accessToken,
      deviceHeaders: DeviceHeaders(
        provider: deviceProvider,
        nonce: requestNonce,
        timestamp: requestTimestamp
      )
    )
  }
}
