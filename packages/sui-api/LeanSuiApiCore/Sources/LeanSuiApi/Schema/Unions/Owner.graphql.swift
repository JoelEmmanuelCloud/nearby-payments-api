// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

extension SuiGraphQL.Unions {
  /// The object's owner kind.
  nonisolated static let Owner = Union(
    name: "Owner",
    possibleTypes: [
      SuiGraphQL.Objects.AddressOwner.self,
      SuiGraphQL.Objects.ObjectOwner.self,
      SuiGraphQL.Objects.Shared.self,
      SuiGraphQL.Objects.Immutable.self,
      SuiGraphQL.Objects.ConsensusAddressOwner.self,
    ]
  )
}
