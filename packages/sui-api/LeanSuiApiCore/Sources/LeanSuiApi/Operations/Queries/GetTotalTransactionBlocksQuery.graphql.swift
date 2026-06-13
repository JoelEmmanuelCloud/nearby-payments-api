// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

extension SuiGraphQL {
  nonisolated struct GetTotalTransactionBlocksQuery: GraphQLQuery {
    static let operationName: String = "getTotalTransactionBlocks"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query getTotalTransactionBlocks { checkpoint { __typename networkTotalTransactions } }"#
      ))

    public init() {}

    nonisolated struct Data: SuiGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Query }
      static var __selections: [ApolloAPI.Selection] {
        [
          .field("checkpoint", Checkpoint?.self)
        ]
      }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
        [
          GetTotalTransactionBlocksQuery.Data.self
        ]
      }

      /// Fetch a checkpoint by its sequence number, or the latest checkpoint if no sequence number is provided.
      ///
      /// Returns `null` if the checkpoint does not exist in the store, either because it never existed or because it was pruned.
      var checkpoint: Checkpoint? { __data["checkpoint"] }

      /// Checkpoint
      ///
      /// Parent Type: `Checkpoint`
      nonisolated struct Checkpoint: SuiGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Checkpoint }
        static var __selections: [ApolloAPI.Selection] {
          [
            .field("__typename", String.self),
            .field("networkTotalTransactions", SuiGraphQL.UInt53?.self),
          ]
        }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
          [
            GetTotalTransactionBlocksQuery.Data.Checkpoint.self
          ]
        }

        /// The total number of transactions in the network by the end of this checkpoint.
        var networkTotalTransactions: SuiGraphQL.UInt53? { __data["networkTotalTransactions"] }
      }
    }
  }

}
