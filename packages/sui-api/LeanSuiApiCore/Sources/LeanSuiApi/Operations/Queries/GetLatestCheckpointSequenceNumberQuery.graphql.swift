// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

extension SuiGraphQL {
  nonisolated struct GetLatestCheckpointSequenceNumberQuery: GraphQLQuery {
    static let operationName: String = "getLatestCheckpointSequenceNumber"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query getLatestCheckpointSequenceNumber { checkpoint { __typename sequenceNumber } }"#
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
          GetLatestCheckpointSequenceNumberQuery.Data.self
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
            .field("sequenceNumber", SuiGraphQL.UInt53.self),
          ]
        }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
          [
            GetLatestCheckpointSequenceNumberQuery.Data.Checkpoint.self
          ]
        }

        /// The checkpoint's position in the total order of finalized checkpoints, agreed upon by consensus.
        var sequenceNumber: SuiGraphQL.UInt53 { __data["sequenceNumber"] }
      }
    }
  }

}
