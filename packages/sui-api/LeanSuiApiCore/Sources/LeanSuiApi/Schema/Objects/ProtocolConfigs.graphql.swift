// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

extension SuiGraphQL.Objects {
  /// Constants that control how the chain operates.
  ///
  /// These can only change during protocol upgrades which happen on epoch boundaries. Configuration is split into feature flags (which are just booleans), and configs which can take any value (including no value at all), and will be represented by a string.
  nonisolated static let ProtocolConfigs = ApolloAPI.Object(
    typename: "ProtocolConfigs",
    implementedInterfaces: [],
    keyFields: nil
  )
}
