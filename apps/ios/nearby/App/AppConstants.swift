//
//  AppConstants.swift
//  nearby
//

import Foundation
import LeanSuiApi

/// Global, immutable, `Sendable` configuration. Explicitly `nonisolated` so it reads from any
/// isolation (the app target defaults to `@MainActor`, which would otherwise isolate these constants
/// and break access from actors / nonisolated default-argument contexts, e.g. `BalanceService`).
nonisolated enum AppConstants {
  static let baseURLString = "https://nearby-api.variance.space"
  static let apiVersion = "v1"
  static let googleServerClientID =
    "565533426961-glfffimsek0cni5pq7e7hfmi2umm0e5i.apps.googleusercontent.com"

  /// The Sui network used for zkLogin (epoch lookups, proofs, transactions) and the on-chain balance.
  static let suiNetwork: SuiNetworkKind = .testnet

  /// Number of epochs ahead of the current epoch that a zkLogin ephemeral key stays valid.
  static let suiMaxEpochBuffer: UInt64 = 2

  static let remoteZkProverURL = "https://prover.variance.space/v1"

  /// USDsui — Sui's native USD stablecoin (mainnet). Used for the Home account balance.
  static let usdSuiCoinType =
    "0xa1ec7fc00a6f40db9693ad1415d0c193ad3906494428cf252621037bd7117e29::usdc::USDC"  // "0x44f838219cf67b058f3b37907b655f226153c18e33dfcd0da559a844fea9b1c1::usdsui::USDSUI" temp switch

  /// Display symbol + entry precision for the balance coin, shared by the Home balance and send amount.
  static let balanceCoinSymbol = "USDsui"
  static let balanceCoinDecimals = 6

  /// How often the Home account balance silently refreshes.
  static let balanceRefreshInterval: TimeInterval = 30

  /// Debounce before checking SuiNS name availability as the user types.
  static let nameCheckDebounce: TimeInterval = 0.5
}
