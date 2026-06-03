//
//  Coin+Mapping.swift
//  LeanSuiApi
//
//  Generated SelectionSet -> domain DTO conversions for the coin endpoints.
//  This is the only place Apollo-generated coin types are referenced.
//

import Foundation

extension SuiCoinMetadata {
  init(graphql m: GetCoinMetadataQuery.Data.CoinMetadata) {
    self.init(
      address: m.address,
      decimals: m.decimals,
      name: m.name,
      symbol: m.symbol,
      description: m.description,
      iconURL: m.iconUrl
    )
  }
}

extension CoinBalance {
  /// From `getBalance`.
  init(graphql b: GetBalanceQuery.Data.Address.Balance) throws {
    let total = try Scalars.uInt64(b.totalBalance ?? "0", field: "balance.totalBalance")
    self.init(coinType: b.coinType?.repr, totalBalance: total)
  }

  /// From `getAllBalances` node.
  init(graphql n: GetAllBalancesQuery.Data.Address.Balances.Node) throws {
    let total = try Scalars.uInt64(n.totalBalance ?? "0", field: "balances.node.totalBalance")
    self.init(coinType: n.coinType?.repr, totalBalance: total)
  }
}

extension PageInfo {
  init(graphql p: GetAllBalancesQuery.Data.Address.Balances.PageInfo) {
    self.init(
      hasNextPage: p.hasNextPage,
      hasPreviousPage: false,
      startCursor: nil,
      endCursor: p.endCursor
    )
  }

  init(graphql p: GetCoinsQuery.Data.Address.Objects.PageInfo) {
    self.init(
      hasNextPage: p.hasNextPage,
      hasPreviousPage: false,
      startCursor: nil,
      endCursor: p.endCursor
    )
  }
}

extension CoinStruct {
  /// From a `getCoins` node. The coin balance lives inside the object's
  /// `contents.json` (`{ "id": ..., "balance": "<u64>" }`).
  init(graphql n: GetCoinsQuery.Data.Address.Objects.Node) throws {
    let version = try Scalars.uInt64(require(n.version, "coin.version"), field: "coin.version")
    var balance: UInt64 = 0
    if case let dict as [String: Any] = n.contents?.json?.rawValue,
      let raw = dict["balance"] as? String, let parsed = UInt64(raw)
    {
      balance = parsed
    }
    self.init(
      coinObjectId: n.address,
      version: version,
      digest: n.digest,
      coinType: n.contents?.type?.repr,
      balance: balance,
      previousTransaction: n.previousTransaction?.digest
    )
  }
}
