//
//  SystemState.swift
//  LeanSuiApi
//
//  Owned system-state / validator / protocol-config DTOs.
//
//  NOTE: the Sui GraphQL schema no longer exposes structured per-validator
//  fields (address / credentials / votingPower) or structured epoch system
//  parameters — those now live inside opaque `MoveValue` blobs. So these DTOs
//  keep the still-typed epoch-level fields and expose the validator-set and
//  system-state `contents` as raw JSON strings (the "escape hatch") for callers
//  that need the buried detail.
//

import Foundation

/// Summary of the latest Sui system state (current epoch).
public struct SuiSystemStateSummary: Sendable, Equatable {
  public let epoch: UInt64
  public let protocolVersion: UInt64?
  public let referenceGasPrice: UInt64?
  public let totalGasFees: UInt64?
  public let totalStakeRewards: UInt64?
  public let totalStakeSubsidies: UInt64?
  public let totalTransactions: UInt64?
  public let storageFundSize: UInt64?
  public let startTimestamp: Date?
  public let endTimestamp: Date?
  /// Raw JSON of the on-chain system state inner object.
  public let systemStateJSON: String?
  /// Raw JSON of the on-chain `ValidatorSet` value (contains per-validator detail).
  public let validatorSetJSON: String?

  public init(
    epoch: UInt64,
    protocolVersion: UInt64?,
    referenceGasPrice: UInt64?,
    totalGasFees: UInt64?,
    totalStakeRewards: UInt64?,
    totalStakeSubsidies: UInt64?,
    totalTransactions: UInt64?,
    storageFundSize: UInt64?,
    startTimestamp: Date?,
    endTimestamp: Date?,
    systemStateJSON: String?,
    validatorSetJSON: String?
  ) {
    self.epoch = epoch
    self.protocolVersion = protocolVersion
    self.referenceGasPrice = referenceGasPrice
    self.totalGasFees = totalGasFees
    self.totalStakeRewards = totalStakeRewards
    self.totalStakeSubsidies = totalStakeSubsidies
    self.totalTransactions = totalTransactions
    self.storageFundSize = storageFundSize
    self.startTimestamp = startTimestamp
    self.endTimestamp = endTimestamp
    self.systemStateJSON = systemStateJSON
    self.validatorSetJSON = validatorSetJSON
  }
}

/// The protocol configuration for a given version.
public struct ProtocolConfig: Sendable, Equatable {
  public let protocolVersion: UInt64
  /// Config key → value (value is a string; absent when the config has no value).
  public let configs: [String: String?]
  /// Feature flag key → enabled.
  public let featureFlags: [String: Bool]

  public init(protocolVersion: UInt64, configs: [String: String?], featureFlags: [String: Bool]) {
    self.protocolVersion = protocolVersion
    self.configs = configs
    self.featureFlags = featureFlags
  }
}

/// Committee information for an epoch. Per-validator voting weights are no
/// longer typed in the schema; the raw `ValidatorSet` JSON is surfaced instead.
public struct CommitteeInfo: Sendable, Equatable {
  public let epoch: UInt64
  /// Raw JSON of the on-chain `ValidatorSet` value.
  public let validatorSetJSON: String?

  public init(epoch: UInt64, validatorSetJSON: String?) {
    self.epoch = epoch
    self.validatorSetJSON = validatorSetJSON
  }
}

/// Validator APY information. APY is derived client-side from exchange-rate
/// tables inside the validator set; this lean client surfaces the raw
/// `ValidatorSet` JSON rather than computing it.
public struct ValidatorApys: Sendable, Equatable {
  public let epoch: UInt64
  /// Raw JSON of the on-chain `ValidatorSet` value.
  public let validatorSetJSON: String?

  public init(epoch: UInt64, validatorSetJSON: String?) {
    self.epoch = epoch
    self.validatorSetJSON = validatorSetJSON
  }
}
