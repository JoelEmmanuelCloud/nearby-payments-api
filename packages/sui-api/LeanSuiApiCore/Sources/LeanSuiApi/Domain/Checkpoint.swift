//
//  Checkpoint.swift
//  LeanSuiApi
//
//  Owned checkpoint domain DTOs. Gas amounts and sequence/epoch numbers are
//  `u64` on-chain (per-field Move ABI widths).
//

import Foundation

/// Rolling gas cost summary for a checkpoint.
public struct GasCostSummary: Sendable, Equatable {
  public let computationCost: UInt64
  public let storageCost: UInt64
  public let storageRebate: UInt64
  public let nonRefundableStorageFee: UInt64

  public init(
    computationCost: UInt64,
    storageCost: UInt64,
    storageRebate: UInt64,
    nonRefundableStorageFee: UInt64
  ) {
    self.computationCost = computationCost
    self.storageCost = storageCost
    self.storageRebate = storageRebate
    self.nonRefundableStorageFee = nonRefundableStorageFee
  }
}

/// A finalized checkpoint.
public struct Checkpoint: Sendable, Equatable {
  public let digest: String?
  public let sequenceNumber: UInt64
  public let epoch: UInt64?
  public let networkTotalTransactions: UInt64?
  public let previousCheckpointDigest: String?
  public let timestamp: Date?
  public let rollingGasSummary: GasCostSummary?
  /// Digests of the transactions included in this checkpoint.
  public let transactionDigests: [String]
  /// Base64-encoded aggregated validator signature, if present.
  public let validatorSignature: String?

  public init(
    digest: String?,
    sequenceNumber: UInt64,
    epoch: UInt64?,
    networkTotalTransactions: UInt64?,
    previousCheckpointDigest: String?,
    timestamp: Date?,
    rollingGasSummary: GasCostSummary?,
    transactionDigests: [String],
    validatorSignature: String?
  ) {
    self.digest = digest
    self.sequenceNumber = sequenceNumber
    self.epoch = epoch
    self.networkTotalTransactions = networkTotalTransactions
    self.previousCheckpointDigest = previousCheckpointDigest
    self.timestamp = timestamp
    self.rollingGasSummary = rollingGasSummary
    self.transactionDigests = transactionDigests
    self.validatorSignature = validatorSignature
  }
}
