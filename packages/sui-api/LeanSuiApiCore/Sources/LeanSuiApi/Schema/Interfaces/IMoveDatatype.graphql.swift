// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

extension SuiGraphQL.Interfaces {
  /// Interface implemented by all GraphQL types that represent a Move datatype definition (either a struct or an enum definition).
  ///
  /// This interface is used to provide a way to access fields that are shared by both structs and enums, e.g., the module that the datatype belongs to, the name of the datatype, type parameters etc.
  nonisolated static let IMoveDatatype = ApolloAPI.Interface(
    name: "IMoveDatatype",
    keyFields: nil,
    implementingObjects: [
      "MoveDatatype",
      "MoveEnum",
      "MoveStruct",
    ]
  )
}
