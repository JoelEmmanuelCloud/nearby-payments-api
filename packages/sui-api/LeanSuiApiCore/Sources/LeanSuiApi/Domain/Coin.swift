//
//  Coin.swift
//  LeanSuiApi
//
//  Owned coin domain DTOs. On Sui, coin balances and supply are `u64`
//  on-chain, so they map to `UInt64` (per-field Move ABI widths).
//

import Foundation

/// Metadata (symbol, decimals, …) for a coin type.
public struct SuiCoinMetadata: Sendable, Equatable {
  public let address: String
  public let decimals: Int?
  public let name: String?
  public let symbol: String?
  public let description: String?
  public let iconURL: String?

  public init(
    address: String,
    decimals: Int?,
    name: String?,
    symbol: String?,
    description: String?,
    iconURL: String?
  ) {
    self.address = address
    self.decimals = decimals
    self.name = name
    self.symbol = symbol
    self.description = description
    self.iconURL = iconURL
  }
}

/// Total balance for a single coin type owned by an address.
public struct CoinBalance: Sendable, Equatable {
  /// Fully-qualified coin type, e.g. `0x2::sui::SUI`. May be absent if the
  /// node could not resolve the type.
  public let coinType: String?
  /// Total balance across all coin objects of this type (`u64` on-chain).
  public let totalBalance: UInt64

  public init(coinType: String?, totalBalance: UInt64) {
    self.coinType = coinType
    self.totalBalance = totalBalance
  }
}

/// A single coin object owned by an address. Carries the object reference
/// (id/version/digest) needed for gas selection plus the coin's balance.
public struct CoinStruct: Sendable, Equatable {
  public let coinObjectId: String
  public let version: UInt64
  public let digest: String?
  /// Fully-qualified coin type, e.g. `0x2::sui::SUI`.
  public let coinType: String?
  /// The coin's balance (`u64` on-chain).
  public let balance: UInt64
  /// The transaction digest that created this version of the coin.
  public let previousTransaction: String?

  public init(
    coinObjectId: String,
    version: UInt64,
    digest: String?,
    coinType: String?,
    balance: UInt64,
    previousTransaction: String?
  ) {
    self.coinObjectId = coinObjectId
    self.version = version
    self.digest = digest
    self.coinType = coinType
    self.balance = balance
    self.previousTransaction = previousTransaction
  }
}
