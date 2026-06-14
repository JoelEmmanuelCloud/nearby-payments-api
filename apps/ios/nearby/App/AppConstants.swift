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
  static let balanceRefreshInterval: TimeInterval = 15

  /// Debounce before checking SuiNS name availability as the user types.
  static let nameCheckDebounce: TimeInterval = 0.5

  /// Deadline for one-shot network lookups (name check / resolution, activity refresh) before they
  /// time out and surface a toast, rather than spinning forever on a stalled connection.
  static let networkTimeout: TimeInterval = 12

  /// DEBUG ONLY — leave `false`. When `true`, the zkLogin session is treated as expired so the
  /// just-in-time re-login (OAuth) path runs on the next sign. To test: set `true`, **cold-launch**
  /// the app (so the in-memory ephemeral is cleared), then tap Send or "Move to balance" — the OAuth
  /// sheet should appear, re-auth, and the action complete. Set back to `false` afterwards.
  static let debugForceSessionExpired = false

  /// Full 32-byte genesis checkpoint digests (the chain identifier) per network, base58-encoded.
  /// These are the canonical values from `sui-types` (their first 4 bytes are the familiar short
  /// chain ids — testnet `4c78adac`, mainnet `35834a8a`). Used in the `ValidDuring` expiration of
  /// gasless (address-balance) transactions for cross-chain replay protection.
  static let suiTestnetGenesisDigestBase58 = "69WiPg3DAQiwdxfncX6wYQ2siKwAe6L9BZthQea3JNMD"
  static let suiMainnetGenesisDigestBase58 = "4btiuiMPvEENsttpZC7CZ53DruC3MAgfznDbASZ7DR6S"

  /// The base58 genesis digest for the configured network.
  static var suiChainIdentifierBase58: String {
    switch suiNetwork {
    case .mainnet: return suiMainnetGenesisDigestBase58
    default: return suiTestnetGenesisDigestBase58
    }
  }
}
