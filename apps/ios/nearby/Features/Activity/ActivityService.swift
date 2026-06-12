import Foundation
import LeanSuiApi

/// IO boundary for the on-chain activity feed. Wraps a GraphQL provider and forwards to the shared
/// `getActivity` (which does the fetch + fold + format), scoped to the configured balance coin.
actor ActivityService {
  private let provider: GraphQLSuiProvider
  private let coinType: String

  init(network: SuiNetworkKind, coinType: String) {
    self.provider = GraphQLSuiProvider(network: SuiNetwork(kind: network))
    self.coinType = coinType
  }

  /// One page of the address's activity, newest first. Pass `cursor` = nil for the first page.
  /// Page size is owned by the package (`getActivity`) since it's bounded by the GraphQL query cost.
  func activity(address: String, cursor: String?) async throws -> SuiActivityFeed {
    try await provider.getActivity(address: address, coinType: coinType, cursor: cursor)
  }
}
