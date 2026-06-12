//
//  AccountActivity+Mapping.swift
//  LeanSuiApi
//
//  Conversions from the lean `ACCOUNT_ACTIVITY_FIELDS` fragment (the cost-bounded list query) to the
//  transaction domain DTO. Reuses `SuiTransactionBlockResponse` so the same tested `SuiActivity.make`
//  fold serves both the lean list and the rich per-digest detail.
//

import Foundation

extension BalanceChange {
  init(activity n: ACCOUNT_ACTIVITY_FIELDS.Effects.BalanceChanges.Node) {
    self.init(coinType: n.coinType?.repr, owner: n.owner?.address, amount: n.amount)
  }
}

extension TransactionEffects {
  init(activity e: ACCOUNT_ACTIVITY_FIELDS.Effects) throws {
    let status: TransactionExecutionStatus? = e.status.flatMap {
      switch $0 {
      case .case(.success): return .success
      case .case(.failure): return .failure
      case .unknown: return nil
      }
    }
    let timestamp = try e.timestamp.map { try Scalars.date($0, field: "effects.timestamp") }

    self.init(
      status: status,
      executionError: e.executionError?.message,
      // Not selected by the lean activity query (and unused by the row); the heavy
      // `getTransactionBlock` path carries the checkpoint for detail views.
      checkpointSequenceNumber: nil,
      timestamp: timestamp,
      bcs: nil,
      balanceChanges: e.balanceChanges?.nodes.map { BalanceChange(activity: $0) } ?? []
    )
  }
}

extension PageInfo {
  init(activity p: QueryAccountActivityQuery.Data.Transactions.PageInfo) {
    self.init(
      hasNextPage: p.hasNextPage,
      hasPreviousPage: p.hasPreviousPage,
      startCursor: p.startCursor,
      endCursor: p.endCursor
    )
  }
}

extension SuiTransactionBlockResponse {
  init(activity f: ACCOUNT_ACTIVITY_FIELDS) throws {
    self.init(
      digest: f.digest,
      sender: f.sender?.address,
      signatures: [],
      rawTransaction: nil,
      effects: try f.effects.map { try TransactionEffects(activity: $0) }
    )
  }
}
