//
//  AppConstants.swift
//  nearby
//

import Foundation
import LeanSuiApi

enum AppConstants {
  static let baseURLString = "https://nearby-api.variance.space"
  static let apiVersion = "v1"
  static let googleClientID =
    "565533426961-glfffimsek0cni5pq7e7hfmi2umm0e5i.apps.googleusercontent.com"

  /// The Sui network used for zkLogin (epoch lookups, proofs, transactions) and the on-chain balance.
  static let suiNetwork: SuiNetworkKind = .mainnet

  /// Number of epochs ahead of the current epoch that a zkLogin ephemeral key stays valid.
  static let suiMaxEpochBuffer: UInt64 = 2

  static let remoteZkProverURL = "https://variance.outray.app/v1"

  /// USDsui — Sui's native USD stablecoin (mainnet). Used for the Home account balance.
  static let usdSuiCoinType =
    "0x44f838219cf67b058f3b37907b655f226153c18e33dfcd0da559a844fea9b1c1::usdsui::USDSUI"

  /// How often the Home account balance silently refreshes.
  static let balanceRefreshInterval: TimeInterval = 30

  /// Debounce before checking SuiNS name availability as the user types.
  static let nameCheckDebounce: TimeInterval = 0.5
}
