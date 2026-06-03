//
//  Checkpoint+Mapping.swift
//  LeanSuiApi
//
//  Conversions from the shared `RPC_Checkpoint_Fields` fragment to the
//  `Checkpoint` domain DTO. Both `getCheckpoint` and `getCheckpoints` expose
//  this fragment, so one mapping serves both.
//

import Foundation

extension PageInfo {
  init(graphql p: GetCheckpointsQuery.Data.Checkpoints.PageInfo) {
    self.init(
      hasNextPage: p.hasNextPage,
      hasPreviousPage: p.hasPreviousPage,
      startCursor: p.startCursor,
      endCursor: p.endCursor
    )
  }
}

extension GasCostSummary {
  init(graphql g: RPC_Checkpoint_Fields.RollingGasSummary) throws {
    self.init(
      computationCost: try Scalars.uInt64(g.computationCost ?? "0", field: "gas.computationCost"),
      storageCost: try Scalars.uInt64(g.storageCost ?? "0", field: "gas.storageCost"),
      storageRebate: try Scalars.uInt64(g.storageRebate ?? "0", field: "gas.storageRebate"),
      nonRefundableStorageFee: try Scalars.uInt64(
        g.nonRefundableStorageFee ?? "0",
        field: "gas.nonRefundableStorageFee"
      )
    )
  }
}

extension Checkpoint {
  init(graphql c: RPC_Checkpoint_Fields) throws {
    let epoch = try c.epoch.map {
      try Scalars.uInt64($0.epochId, field: "checkpoint.epoch.epochId")
    }
    let networkTotal = try c.networkTotalTransactions.map {
      try Scalars.uInt64($0, field: "checkpoint.networkTotalTransactions")
    }
    let timestamp = try c.timestamp.map { try Scalars.date($0, field: "checkpoint.timestamp") }
    let gas = try c.rollingGasSummary.map { try GasCostSummary(graphql: $0) }

    self.init(
      digest: c.digest,
      sequenceNumber: try Scalars.uInt64(c.sequenceNumber, field: "checkpoint.sequenceNumber"),
      epoch: epoch,
      networkTotalTransactions: networkTotal,
      previousCheckpointDigest: c.previousCheckpointDigest,
      timestamp: timestamp,
      rollingGasSummary: gas,
      transactionDigests: c.transactions?.nodes.map { $0.digest } ?? [],
      validatorSignature: c.validatorSignatures?.signature
    )
  }
}
