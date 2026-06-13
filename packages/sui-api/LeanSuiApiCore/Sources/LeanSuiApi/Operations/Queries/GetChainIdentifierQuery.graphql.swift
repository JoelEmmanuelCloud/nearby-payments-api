// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

extension SuiGraphQL {
  nonisolated struct GetChainIdentifierQuery: GraphQLQuery {
    static let operationName: String = "getChainIdentifier"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query getChainIdentifier { chainIdentifier }"#
      ))

    public init() {}

    nonisolated struct Data: SuiGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Query }
      static var __selections: [ApolloAPI.Selection] {
        [
          .field("chainIdentifier", String.self)
        ]
      }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
        [
          GetChainIdentifierQuery.Data.self
        ]
      }

      /// The network's genesis checkpoint digest (uniquely identifies the network), Base58-encoded.
      var chainIdentifier: String { __data["chainIdentifier"] }
    }
  }

}
