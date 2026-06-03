//
//  SystemState+Mapping.swift
//  LeanSuiApi
//
//  Conversions for the system-state / validator / protocol-config / committee
//  and dynamic-field endpoints.
//

import Foundation

extension SuiSystemStateSummary {
  init(graphql e: GetLatestSuiSystemStateQuery.Data.Epoch) throws {
    self.init(
      epoch: try Scalars.uInt64(e.epochId, field: "epoch.epochId"),
      protocolVersion: try e.protocolConfigs.map {
        try Scalars.uInt64($0.protocolVersion, field: "epoch.protocolConfigs.protocolVersion")
      },
      referenceGasPrice: try e.referenceGasPrice.map {
        try Scalars.uInt64($0, field: "epoch.referenceGasPrice")
      },
      totalGasFees: try e.totalGasFees.map { try Scalars.uInt64($0, field: "epoch.totalGasFees") },
      totalStakeRewards: try e.totalStakeRewards.map {
        try Scalars.uInt64($0, field: "epoch.totalStakeRewards")
      },
      totalStakeSubsidies: try e.totalStakeSubsidies.map {
        try Scalars.uInt64($0, field: "epoch.totalStakeSubsidies")
      },
      totalTransactions: try e.totalTransactions.map {
        try Scalars.uInt64($0, field: "epoch.totalTransactions")
      },
      storageFundSize: try e.fundSize.map { try Scalars.uInt64($0, field: "epoch.fundSize") },
      startTimestamp: try e.startTimestamp.map {
        try Scalars.date($0, field: "epoch.startTimestamp")
      },
      endTimestamp: try e.endTimestamp.map { try Scalars.date($0, field: "epoch.endTimestamp") },
      systemStateJSON: e.systemState?.json?.string,
      validatorSetJSON: e.validatorSet?.contents?.json?.string
    )
  }
}

extension ProtocolConfig {
  init(graphql c: GetProtocolConfigQuery.Data.ProtocolConfigs) throws {
    var configs: [String: String?] = [:]
    for cfg in c.configs { configs[cfg.key] = cfg.value }
    var flags: [String: Bool] = [:]
    for flag in c.featureFlags { flags[flag.key] = flag.value }
    self.init(
      protocolVersion: try Scalars.uInt64(
        c.protocolVersion, field: "protocolConfigs.protocolVersion"),
      configs: configs,
      featureFlags: flags
    )
  }
}

extension CommitteeInfo {
  init(graphql e: GetCommitteeInfoQuery.Data.Epoch) throws {
    self.init(
      epoch: try Scalars.uInt64(e.epochId, field: "epoch.epochId"),
      validatorSetJSON: e.validatorSet?.contents?.json?.string
    )
  }
}

extension ValidatorApys {
  init(graphql e: GetValidatorsApyQuery.Data.Epoch) throws {
    self.init(
      epoch: try Scalars.uInt64(e.epochId, field: "epoch.epochId"),
      validatorSetJSON: e.validatorSet?.contents?.json?.string
    )
  }
}

extension DynamicFieldInfo {
  init(graphql n: GetDynamicFieldsQuery.Data.Address.DynamicFields.Node) throws {
    let value = n.value
    self.init(
      nameType: n.name?.type?.repr,
      nameJSON: n.name?.json?.string,
      nameBcs: n.name?.bcs,
      valueType: value?.asMoveValue?.type?.repr ?? value?.asMoveObject?.contents?.type?.repr,
      valueJSON: value?.asMoveValue?.json?.string ?? value?.asMoveObject?.contents?.json?.string,
      objectId: value?.asMoveObject?.address,
      objectDigest: value?.asMoveObject?.digest,
      objectVersion: try value?.asMoveObject?.version.map {
        try Scalars.uInt64($0, field: "dynamicField.value.version")
      } ?? nil
    )
  }
}

extension PageInfo {
  init(graphql p: GetDynamicFieldsQuery.Data.Address.DynamicFields.PageInfo) {
    self.init(
      hasNextPage: p.hasNextPage, hasPreviousPage: false, startCursor: nil, endCursor: p.endCursor)
  }
}
