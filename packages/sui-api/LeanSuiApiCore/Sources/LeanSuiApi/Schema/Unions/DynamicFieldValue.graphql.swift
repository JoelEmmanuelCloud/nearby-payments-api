// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

extension SuiGraphQL.Unions {
  /// The value of a dynamic field (`MoveValue`) or dynamic object field (`MoveObject`).
  nonisolated static let DynamicFieldValue = Union(
    name: "DynamicFieldValue",
    possibleTypes: [
      SuiGraphQL.Objects.MoveObject.self,
      SuiGraphQL.Objects.MoveValue.self,
    ]
  )
}
