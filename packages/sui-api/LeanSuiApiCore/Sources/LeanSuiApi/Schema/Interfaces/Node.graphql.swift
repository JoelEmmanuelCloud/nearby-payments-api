// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

extension SuiGraphQL.Interfaces {
  /// An interface implemented by types that can be uniquely identified by a globally unique `ID`, following the GraphQL Global Object Identification specification.
  nonisolated static let Node = ApolloAPI.Interface(
    name: "Node",
    keyFields: nil,
    implementingObjects: [
      "Address",
      "Checkpoint",
      "DynamicField",
      "Epoch",
      "MoveObject",
      "MovePackage",
      "Object",
      "Transaction",
    ]
  )
}
