//
//  WritePath+Mapping.swift
//  LeanSuiApi
//
//  Conversions for the write-path operations. Their responses are inline in
//  each operation (executeTransaction / simulateTransaction), so these map
//  the per-operation generated types directly.
//

import ApolloAPI
import Foundation

private func mapStatus(_ s: GraphQLEnum<SuiGraphQL.ExecutionStatus>) -> TransactionExecutionStatus?
{
  switch s {
  case .case(.success): return .success
  case .case(.failure): return .failure
  case .unknown: return nil
  }
}

extension SuiTransactionBlockResponse {
  /// From the `executeTransaction` mutation result.
  init(execute e: ExecuteTransactionBlockMutation.Data.ExecuteTransaction) throws {
    let effects = e.effects
    let tx = effects?.transaction
    let status: TransactionExecutionStatus? = effects?.status.flatMap { mapStatus($0) }
    let domainEffects: TransactionEffects? = effects.map { fx in
      TransactionEffects(
        status: status,
        executionError: fx.executionError?.message,
        checkpointSequenceNumber: nil,
        timestamp: nil,
        bcs: fx.effectsBcs,
        balanceChanges: fx.balanceChanges?.nodes.map {
          BalanceChange(coinType: $0.coinType?.repr, owner: $0.owner?.address, amount: $0.amount)
        } ?? []
      )
    }
    self.init(
      digest: tx?.digest ?? "",
      sender: tx?.sender?.address,
      signatures: [],
      rawTransaction: tx?.transactionBcs,
      effects: domainEffects
    )
  }
}

extension DryRunResult {
  /// From the `simulateTransaction` (dry-run) query result.
  init(graphql s: DryRunTransactionBlockQuery.Data.SimulateTransaction) throws {
    let fx = s.effects
    let gas = fx?.gasEffects?.gasSummary
    let gasSummary: GasCostSummary? = try gas.map {
      GasCostSummary(
        computationCost: try Scalars.uInt64(
          $0.computationCost ?? "0", field: "gas.computationCost"),
        storageCost: try Scalars.uInt64($0.storageCost ?? "0", field: "gas.storageCost"),
        storageRebate: try Scalars.uInt64($0.storageRebate ?? "0", field: "gas.storageRebate"),
        nonRefundableStorageFee: try Scalars.uInt64(
          $0.nonRefundableStorageFee ?? "0", field: "gas.nonRefundableStorageFee"
        )
      )
    }
    self.init(
      error: nil,
      status: fx?.status.flatMap { mapStatus($0) },
      executionError: fx?.executionError?.message,
      gasSummary: gasSummary,
      balanceChanges: fx?.balanceChanges?.nodes.map {
        BalanceChange(coinType: $0.coinType?.repr, owner: $0.owner?.address, amount: $0.amount)
      } ?? [],
      effectsBcs: fx?.effectsBcs
    )
  }
}
