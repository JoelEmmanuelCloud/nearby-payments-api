// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

extension SuiGraphQL {
  nonisolated struct GetEpochIdQuery: GraphQLQuery {
    static let operationName: String = "getEpochId"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query getEpochId { epoch { __typename epochId startTimestamp endTimestamp } }"#
      ))

    public init() {}

    nonisolated struct Data: SuiGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Query }
      static var __selections: [ApolloAPI.Selection] {
        [
          .field("epoch", Epoch?.self)
        ]
      }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
        [
          GetEpochIdQuery.Data.self
        ]
      }

      /// Fetch an epoch by its ID, or fetch the latest epoch if no ID is provided.
      ///
      /// Returns `null` if the epoch does not exist yet, or was pruned.
      var epoch: Epoch? { __data["epoch"] }

      /// Epoch
      ///
      /// Parent Type: `Epoch`
      nonisolated struct Epoch: SuiGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Epoch }
        static var __selections: [ApolloAPI.Selection] {
          [
            .field("__typename", String.self),
            .field("epochId", SuiGraphQL.UInt53.self),
            .field("startTimestamp", SuiGraphQL.DateTime?.self),
            .field("endTimestamp", SuiGraphQL.DateTime?.self),
          ]
        }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
          [
            GetEpochIdQuery.Data.Epoch.self
          ]
        }

        /// The epoch's id as a sequence number that starts at 0 and is incremented by one at every epoch change.
        var epochId: SuiGraphQL.UInt53 { __data["epochId"] }
        /// The timestamp associated with the first checkpoint in the epoch.
        var startTimestamp: SuiGraphQL.DateTime? { __data["startTimestamp"] }
        /// The timestamp associated with the last checkpoint in the epoch (or `null` if the epoch has not finished yet).
        var endTimestamp: SuiGraphQL.DateTime? { __data["endTimestamp"] }
      }
    }
  }

}
