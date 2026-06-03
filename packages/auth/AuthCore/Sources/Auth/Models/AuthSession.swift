import Foundation
import Gateway

/// Persisted authentication session used by app routing, API authorization, and zkLogin flows.
public struct AuthSession: Codable, Sendable, Equatable {
  public let accessToken: String
  public let refreshToken: String
  public let userId: String
  public let jwt: String
  public let salt: String
  public let suiAddress: String?
  public let accessExpiresAt: Int64
  public let refreshExpiresAt: Int64
  public let maxEpoch: UInt64
  public let provider: OAuthProvider

  public init(
    accessToken: String,
    refreshToken: String,
    userId: String,
    jwt: String,
    salt: String,
    suiAddress: String? = nil,
    accessExpiresAt: Int64,
    refreshExpiresAt: Int64,
    maxEpoch: UInt64,
    provider: OAuthProvider
  ) {
    self.accessToken = accessToken
    self.refreshToken = refreshToken
    self.userId = userId
    self.jwt = jwt
    self.salt = salt
    self.suiAddress = suiAddress
    self.accessExpiresAt = accessExpiresAt
    self.refreshExpiresAt = refreshExpiresAt
    self.maxEpoch = maxEpoch
    self.provider = provider
  }
}
