// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

extension SuiGraphQL.Unions {
  /// An argument to a programmable transaction command.
  nonisolated static let TransactionArgument = Union(
    name: "TransactionArgument",
    possibleTypes: [
      SuiGraphQL.Objects.GasCoin.self,
      SuiGraphQL.Objects.Input.self,
      SuiGraphQL.Objects.TxResult.self,
    ]
  )
}
