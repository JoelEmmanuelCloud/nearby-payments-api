//
//  DryRun.swift
//  LeanSuiApi
//
//  Owned dry-run / dev-inspect result DTOs. These responses are inline in the
//  GraphQL operations (not the shared transaction fragment), so they get their
//  own light-weight domain types.
//

import Foundation

/// Result of a transaction dry run (`simulateTransaction`).
public struct DryRunResult: Sendable, Equatable {
  /// Non-nil if simulation failed before producing effects.
  public let error: String?
  public let status: TransactionExecutionStatus?
  public let executionError: String?
  /// Gas cost summary produced by the simulation, if available.
  public let gasSummary: GasCostSummary?
  public let balanceChanges: [BalanceChange]
  /// Base64-encoded BCS of the effects, if requested.
  public let effectsBcs: String?

  public init(
    error: String?,
    status: TransactionExecutionStatus?,
    executionError: String?,
    gasSummary: GasCostSummary?,
    balanceChanges: [BalanceChange],
    effectsBcs: String?
  ) {
    self.error = error
    self.status = status
    self.executionError = executionError
    self.gasSummary = gasSummary
    self.balanceChanges = balanceChanges
    self.effectsBcs = effectsBcs
  }
}
