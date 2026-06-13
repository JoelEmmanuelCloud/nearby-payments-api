//
//  Transaction+Mapping.swift
//  LeanSuiApi
//
//  Conversions from the shared `RPC_TRANSACTION_FIELDS` fragment to the
//  transaction domain DTOs. All three transaction endpoints expose this
//  fragment, so one mapping serves them all.
//

import Foundation

extension BalanceChange {
  init(graphql n: RPC_TRANSACTION_FIELDS.Effects.BalanceChanges.Node) {
    self.init(coinType: n.coinType?.repr, owner: n.owner?.address, amount: n.amount)
  }
}

extension TransactionEffects {
  init(graphql e: RPC_TRANSACTION_FIELDS.Effects) throws {
    let status: TransactionExecutionStatus? = e.status.flatMap {
      switch $0 {
      case .case(.success): return .success
      case .case(.failure): return .failure
      case .unknown: return nil
      }
    }
    let checkpoint = try e.checkpoint.map {
      try Scalars.uInt64($0.sequenceNumber, field: "effects.checkpoint.sequenceNumber")
    }
    let timestamp = try e.timestamp.map { try Scalars.date($0, field: "effects.timestamp") }

    self.init(
      status: status,
      executionError: e.executionError?.message,
      checkpointSequenceNumber: checkpoint,
      timestamp: timestamp,
      bcs: e.bcs,
      balanceChanges: e.balanceChanges?.nodes.map { BalanceChange(graphql: $0) } ?? []
    )
  }
}

extension PageInfo {
  init(graphql p: QueryTransactionBlocksQuery.Data.Transactions.PageInfo) {
    self.init(
      hasNextPage: p.hasNextPage,
      hasPreviousPage: p.hasPreviousPage,
      startCursor: p.startCursor,
      endCursor: p.endCursor
    )
  }
}

extension SuiTransactionBlockResponse {
  init(graphql f: RPC_TRANSACTION_FIELDS) throws {
    self.init(
      digest: f.digest,
      sender: f.sender?.address,
      signatures: f.signatures.compactMap { $0.signatureBytes },
      rawTransaction: f.rawTransaction,
      effects: try f.effects.map { try TransactionEffects(graphql: $0) }
    )
  }
}
