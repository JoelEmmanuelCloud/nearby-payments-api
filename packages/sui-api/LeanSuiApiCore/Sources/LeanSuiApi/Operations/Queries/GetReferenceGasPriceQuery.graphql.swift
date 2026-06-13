// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

extension SuiGraphQL {
  nonisolated struct GetReferenceGasPriceQuery: GraphQLQuery {
    static let operationName: String = "getReferenceGasPrice"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query getReferenceGasPrice { epoch { __typename referenceGasPrice } }"#
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
          GetReferenceGasPriceQuery.Data.self
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
            .field("referenceGasPrice", SuiGraphQL.BigInt?.self),
          ]
        }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
          [
            GetReferenceGasPriceQuery.Data.Epoch.self
          ]
        }

        /// The minimum gas price that a quorum of validators are guaranteed to sign a transaction for in this epoch.
        var referenceGasPrice: SuiGraphQL.BigInt? { __data["referenceGasPrice"] }
      }
    }
  }

}
