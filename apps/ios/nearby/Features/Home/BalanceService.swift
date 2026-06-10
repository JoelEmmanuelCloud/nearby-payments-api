import Foundation
import LeanSuiApi

/// IO boundary for the on-chain USDsui balance. Wraps a mainnet GraphQL provider and is single-purpose:
/// it returns the owner's USDsui balance as a scaled `Decimal`. An `actor` so the one-time decimals
/// lookup is cached safely across polls.
actor BalanceService {
  private let provider: GraphQLSuiProvider
  private let coinType: String

  private var cachedDecimals: Int?

  init(
    network: SuiNetworkKind = AppConstants.suiNetwork,
    coinType: String = AppConstants.usdSuiCoinType
  ) {
    self.provider = GraphQLSuiProvider(network: SuiNetwork(kind: network))
    self.coinType = coinType
  }

  /// The owner's USDsui balance, scaled by the token's decimals.
  func usdSuiBalance(owner: String) async throws -> Decimal {
    let decimals = try await decimals()
    let raw = try await provider.getBalance(owner: owner, coinType: coinType).totalBalance
    return Decimal(raw) / pow(Decimal(10), decimals)
  }

  private func decimals() async throws -> Int {
    if let cachedDecimals { return cachedDecimals }
    let decimals = try await provider.getCoinMetadata(coinType: coinType).decimals ?? 6
    cachedDecimals = decimals
    return decimals
  }
}
