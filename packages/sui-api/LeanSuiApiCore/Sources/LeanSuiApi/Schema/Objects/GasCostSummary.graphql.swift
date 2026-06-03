// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

extension SuiGraphQL.Objects {
  /// Summary of charges from transactions.
  ///
  /// Storage is charged in three parts -- `storage_cost`, `-storage_rebate`, and `non_refundable_storage_fee` -- independently of `computation_cost`.
  ///
  /// The overall cost of a transaction, deducted from its gas coins, is its `computation_cost + storage_cost - storage_rebate`. `non_refundable_storage_fee` is collected from objects being mutated or deleted and accumulated by the system in storage funds, the remaining storage costs of previous object versions are what become the `storage_rebate`. The ratio between `non_refundable_storage_fee` and `storage_rebate` is set by the protocol.
  nonisolated static let GasCostSummary = ApolloAPI.Object(
    typename: "GasCostSummary",
    implementedInterfaces: [],
    keyFields: nil
  )
}
