/// A unified user profile containing off-chain metadata (from the gateway)
/// and on-chain naming details (resolved directly via SuiNS).
public struct IdentityProfile: Codable, Sendable, Equatable {
  public let userId: String
  public let status: String
  public let avatarUrl: String?
  public let suiAddress: String?
  public let suinsName: String?
  public let createdAt: Int64

  public init(
    userId: String,
    status: String,
    avatarUrl: String? = nil,
    suiAddress: String? = nil,
    suinsName: String? = nil,
    createdAt: Int64
  ) {
    self.userId = userId
    self.status = status
    self.avatarUrl = avatarUrl
    self.suiAddress = suiAddress
    self.suinsName = suinsName
    self.createdAt = createdAt
  }
}
