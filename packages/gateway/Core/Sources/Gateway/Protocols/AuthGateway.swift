import Foundation

public protocol AuthGateway: Sendable {

  func serverPublicKey() async throws -> ServerPublicKeyResponse

  func beginOAuth(request: OAuthBeginRequest) async throws -> OAuthBeginResponse

  func completeOAuth(request: OAuthCompleteRequest) async throws -> OAuthCompleteResponse

  func refresh(
    request: RefreshRequest,
    accessToken: String
  ) async throws -> RefreshResponse

  func revoke(accessToken: String) async throws

  func assertIntegrity(
    request: IntegrityRequest,
    accessToken: String,
    deviceProvider: String,
    requestNonce: String,
    requestTimestamp: String
  ) async throws

  func issueCredential(
    request: CredentialRequest,
    accessToken: String,
    deviceProvider: String,
    requestNonce: String,
    requestTimestamp: String
  ) async throws -> DeviceCredential
}
