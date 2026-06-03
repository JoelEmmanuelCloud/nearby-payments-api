//
//  Transaction.swift
//  LeanSuiApi
//
//  Owned transaction-block domain DTOs. Mirrors the canonical Sui transaction
//  response model (digest, sender, signatures, effects, balance changes).
//

import Foundation

/// Execution status of a transaction.
public enum TransactionExecutionStatus: String, Sendable, Equatable {
  case success
  case failure
}

/// A change to an address's coin balance produced by a transaction.
public struct BalanceChange: Sendable, Equatable {
  public let coinType: String?
  public let owner: String?
  /// Signed amount (can be negative) as a decimal string — the on-chain
  /// `BigInt` is signed, so it is kept verbatim rather than coerced to `UInt`.
  public let amount: String?

  public init(coinType: String?, owner: String?, amount: String?) {
    self.coinType = coinType
    self.owner = owner
    self.amount = amount
  }
}

/// Effects of an executed transaction.
public struct TransactionEffects: Sendable, Equatable {
  public let status: TransactionExecutionStatus?
  public let executionError: String?
  public let checkpointSequenceNumber: UInt64?
  public let timestamp: Date?
  /// Base64-encoded BCS of the effects, if requested.
  public let bcs: String?
  public let balanceChanges: [BalanceChange]

  public init(
    status: TransactionExecutionStatus?,
    executionError: String?,
    checkpointSequenceNumber: UInt64?,
    timestamp: Date?,
    bcs: String?,
    balanceChanges: [BalanceChange]
  ) {
    self.status = status
    self.executionError = executionError
    self.checkpointSequenceNumber = checkpointSequenceNumber
    self.timestamp = timestamp
    self.bcs = bcs
    self.balanceChanges = balanceChanges
  }
}

/// A transaction block response.
public struct SuiTransactionBlockResponse: Sendable, Equatable {
  public let digest: String
  public let sender: String?
  /// Base64-encoded user signatures.
  public let signatures: [String]
  /// Base64-encoded BCS of the raw transaction, if requested.
  public let rawTransaction: String?
  public let effects: TransactionEffects?

  /// Convenience: the effects' checkpoint timestamp, if present.
  public var timestampMs: Date? { effects?.timestamp }

  public init(
    digest: String,
    sender: String?,
    signatures: [String],
    rawTransaction: String?,
    effects: TransactionEffects?
  ) {
    self.digest = digest
    self.sender = sender
    self.signatures = signatures
    self.rawTransaction = rawTransaction
    self.effects = effects
  }
}
