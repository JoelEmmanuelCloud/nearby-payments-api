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
    "565533426961-6hon2pd64ebbuor9sm0lk60ree6kea7b.apps.googleusercontent.com"

  /// The Sui network used for zkLogin (epoch lookups, proofs, transactions).
  static let suiNetwork: SuiNetworkKind = .testnet

  /// Number of epochs ahead of the current epoch that a zkLogin ephemeral key stays valid.
  static let suiMaxEpochBuffer: UInt64 = 2
}
