import Foundation
import LeanSuiApi

/// The owner's balance for the app coin, split across the two places value can live: the
/// account-style **address balance** (spendable gaslessly) and classic **`Coin<T>` objects** (a
/// "pending" balance that must be explicitly consolidated into the address balance first).
struct BalanceBreakdown: Equatable {
  /// Spendable now: the address-balance accumulator. Source for gasless `send_funds`.
  let addressBalance: Decimal
  /// Pending: value held as `Coin<T>` objects, awaiting consolidation. `0` when none.
  let coinBalance: Decimal

  /// Combined holdings (what the node's `totalBalance` reports).
  var total: Decimal { addressBalance + coinBalance }
}

/// IO boundary for the on-chain balance. Wraps a GraphQL provider and returns the owner's balance
/// split into its address-balance (spendable) and coin-object (pending) parts. An `actor` so the
/// one-time decimals lookup is cached safely across polls.
actor BalanceService {
  private let provider: GraphQLSuiProvider
  private let coinType: String

  private var cachedDecimals: Int?

  init(network: SuiNetworkKind, coinType: String) {
    self.provider = GraphQLSuiProvider(network: SuiNetwork(kind: network))
    self.coinType = coinType
  }

  /// The owner's spendable (address-balance) holdings, scaled by the token's decimals. Convenience
  /// over ``breakdown(owner:)`` for callers that only care about what can be sent right now.
  func usdSuiBalance(owner: String) async throws -> Decimal {
    try await breakdown(owner: owner).addressBalance
  }

  /// The owner's balance split into address-balance (spendable) and coin-object (pending) parts.
  ///
  /// `totalBalance` from the node already aggregates both pools, and summing the owner's coin objects
  /// gives the pending part — so the address balance is their difference. This avoids depending on a
  /// dedicated address-balance field while staying exact.
  func breakdown(owner: String) async throws -> BalanceBreakdown {
    let scale = pow(Decimal(10), try await decimals())

    let total = Decimal(
      try await provider.getBalance(owner: owner, coinType: coinType).totalBalance)
    let coins = Decimal(try await totalCoinObjectBalance(owner: owner))
    let address = max(total - coins, 0)  // guard against a transient over-count

    return BalanceBreakdown(addressBalance: address / scale, coinBalance: coins / scale)
  }

  /// Sum of every `Coin<coinType>` object the owner holds (`u64` base units), paginated to be exact.
  private func totalCoinObjectBalance(owner: String) async throws -> UInt64 {
    let wrappedType = "0x2::coin::Coin<\(coinType)>"
    var total: UInt64 = 0
    var cursor: String?
    repeat {
      let page = try await provider.getCoins(owner: owner, coinType: wrappedType, cursor: cursor)
      for coin in page.data { total &+= coin.balance }
      cursor = page.pageInfo.hasNextPage ? page.pageInfo.endCursor : nil
    } while cursor != nil
    return total
  }

  private func decimals() async throws -> Int {
    if let cachedDecimals { return cachedDecimals }
    let decimals = try await provider.getCoinMetadata(coinType: coinType).decimals ?? 6
    cachedDecimals = decimals
    return decimals
  }
}
