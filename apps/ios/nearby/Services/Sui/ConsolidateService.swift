import Foundation
import LeanSui
import LeanSuiApi

/// Moves the owner's `Coin<T>` objects (the "pending" balance) into their **address balance** so they
/// become spendable by the gasless send. The single-purpose counterpart to `SendService`: one gasless
/// transaction calling `0x2::coin::send_funds<T>(coin, self)` for each coin object — which consumes
/// the coins into the address balance without writing any object, so it qualifies as a gasless
/// stablecoin transfer (no SUI required).
struct ConsolidateService {
  enum ConsolidateError: LocalizedError {
    case nothingToConsolidate

    var errorDescription: String? {
      switch self {
      case .nothingToConsolidate: return "No pending balance to move."
      }
    }
  }

  private let runner: GaslessTransactionRunner
  private let provider: GraphQLSuiProvider
  private let coinType: String

  init(
    network: SuiNetworkKind = AppConstants.suiNetwork,
    coinType: String = AppConstants.usdSuiCoinType,
    signerProvider: @escaping () async throws -> ZkLoginSigner
  ) {
    self.runner = GaslessTransactionRunner(network: network, signerProvider: signerProvider)
    self.provider = GraphQLSuiProvider(network: SuiNetwork(kind: network))
    self.coinType = coinType
  }

  /// Consolidates every `Coin<coinType>` object the owner holds into their address balance. Returns
  /// the executed transaction digest, or throws `.nothingToConsolidate` when there are no coins.
  @discardableResult
  func consolidate() async throws -> String {
    try await runner.run { tx, owner in
      let coinObjectIds = try await provider.getAllCoinObjectIds(owner: owner, coinType: coinType)
      guard !coinObjectIds.isEmpty else { throw ConsolidateError.nothingToConsolidate }
      try tx.gaslessDepositCoins(coinType: coinType, coinObjectIds: coinObjectIds, owner: owner)
    }
  }
}
