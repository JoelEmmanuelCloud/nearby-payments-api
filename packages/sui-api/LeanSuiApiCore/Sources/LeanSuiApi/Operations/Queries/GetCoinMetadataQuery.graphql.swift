// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

extension SuiGraphQL {
  nonisolated struct GetCoinMetadataQuery: GraphQLQuery {
    static let operationName: String = "getCoinMetadata"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query getCoinMetadata($coinType: String!) { coinMetadata(coinType: $coinType) { __typename decimals name symbol description iconUrl address } }"#
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
          GetCoinMetadataQuery.Data.self
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
            .field("decimals", Int?.self),
            .field("name", String?.self),
            .field("symbol", String?.self),
            .field("description", String?.self),
            .field("iconUrl", String?.self),
            .field("address", SuiGraphQL.SuiAddress.self),
          ]
        }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
          [
            GetCoinMetadataQuery.Data.CoinMetadata.self
          ]
        }

        /// Number of decimal places the coin uses.
        var decimals: Int? { __data["decimals"] }
        /// Name for the coin.
        var name: String? { __data["name"] }
        /// Symbol for the coin.
        var symbol: String? { __data["symbol"] }
        /// Description of the coin.
        var description: String? { __data["description"] }
        /// URL for the coin logo.
        var iconUrl: String? { __data["iconUrl"] }
        /// The CoinMetadata's ID.
        var address: SuiGraphQL.SuiAddress { __data["address"] }
      }
    }
  }

}
