// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

extension SuiGraphQL {
  nonisolated struct GetTotalSupplyQuery: GraphQLQuery {
    static let operationName: String = "getTotalSupply"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query getTotalSupply($coinType: String!) { coinMetadata(coinType: $coinType) { __typename supply decimals } }"#
      ))

    public var coinType: String

    public init(coinType: String) {
      self.coinType = coinType
    }

    @_spi(Unsafe) public var __variables: Variables? { ["coinType": coinType] }

    nonisolated struct Data: SuiGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Query }
      static var __selections: [ApolloAPI.Selection] {
        [
          .field("coinMetadata", CoinMetadata?.self, arguments: ["coinType": .variable("coinType")])
        ]
      }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
        [
          GetTotalSupplyQuery.Data.self
        ]
      }

      /// Fetch the CoinMetadata for a given coin type.
      ///
      /// Returns `null` if no CoinMetadata object exists for the given coin type.
      var coinMetadata: CoinMetadata? { __data["coinMetadata"] }

      /// CoinMetadata
      ///
      /// Parent Type: `CoinMetadata`
      nonisolated struct CoinMetadata: SuiGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.CoinMetadata }
        static var __selections: [ApolloAPI.Selection] {
          [
            .field("__typename", String.self),
            .field("supply", SuiGraphQL.BigInt?.self),
            .field("decimals", Int?.self),
          ]
        }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
          [
            GetTotalSupplyQuery.Data.CoinMetadata.self
          ]
        }

        /// The overall balance of coins issued.
        var supply: SuiGraphQL.BigInt? { __data["supply"] }
        /// Number of decimal places the coin uses.
        var decimals: Int? { __data["decimals"] }
      }
    }
  }

}
