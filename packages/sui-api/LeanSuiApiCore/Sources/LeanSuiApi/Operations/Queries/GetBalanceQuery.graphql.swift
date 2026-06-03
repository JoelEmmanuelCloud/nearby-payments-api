// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

extension SuiGraphQL {
  nonisolated struct GetBalanceQuery: GraphQLQuery {
    static let operationName: String = "getBalance"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query getBalance($owner: SuiAddress!, $type: String = "0x2::sui::SUI") { address(address: $owner) { __typename balance(coinType: $type) { __typename coinType { __typename repr } totalBalance } } }"#
      ))

    public var owner: SuiAddress
    public var type: GraphQLNullable<String>

    public init(
      owner: SuiAddress,
      type: GraphQLNullable<String> = "0x2::sui::SUI"
    ) {
      self.owner = owner
      self.type = type
    }

    @_spi(Unsafe) public var __variables: Variables? {
      [
        "owner": owner,
        "type": type,
      ]
    }

    nonisolated struct Data: SuiGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Query }
      static var __selections: [ApolloAPI.Selection] {
        [
          .field("address", Address?.self, arguments: ["address": .variable("owner")])
        ]
      }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
        [
          GetBalanceQuery.Data.self
        ]
      }

      /// Look-up an account by its SuiAddress.
      ///
      /// If `rootVersion` is specified, nested dynamic field accesses will be fetched at or before this version. This can be used to fetch a child or descendant object bounded by its root object's version, when its immediate parent is wrapped, or a value in a dynamic object field. For any wrapped or child (object-owned) object, its root object can be defined recursively as:
      ///
      /// - The root object of the object it is wrapped in, if it is wrapped.
      /// - The root object of its owner, if it is owned by another object.
      /// - The object itself, if it is not object-owned or wrapped.
      ///
      /// Specifying a `rootVersion` disables nested queries for paginating owned objects or dynamic fields (these queries are only supported at checkpoint boundaries).
      ///
      /// If `atCheckpoint` is specified, the address will be fetched at the latest version as of this checkpoint. This will fail if the provided checkpoint is after the RPC's latest checkpoint.
      ///
      /// If none of the above are specified, the address is fetched at the checkpoint being viewed.
      ///
      /// If the address is fetched by name and the name does not resolve to an address (e.g. the name does not exist or has expired), `null` is returned.
      var address: Address? { __data["address"] }

      /// Address
      ///
      /// Parent Type: `Address`
      nonisolated struct Address: SuiGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Address }
        static var __selections: [ApolloAPI.Selection] {
          [
            .field("__typename", String.self),
            .field("balance", Balance?.self, arguments: ["coinType": .variable("type")]),
          ]
        }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
          [
            GetBalanceQuery.Data.Address.self
          ]
        }

        /// Fetch the total balance for coins with marker type `coinType` (e.g. `0x2::sui::SUI`), owned by this address.
        ///
        /// Returns `None` when no checkpoint is set in scope (e.g. execution scope).
        /// If the address does not own any coins of that type, a balance of zero is returned.
        var balance: Balance? { __data["balance"] }

        /// Address.Balance
        ///
        /// Parent Type: `Balance`
        nonisolated struct Balance: SuiGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Balance }
          static var __selections: [ApolloAPI.Selection] {
            [
              .field("__typename", String.self),
              .field("coinType", CoinType?.self),
              .field("totalBalance", SuiGraphQL.BigInt?.self),
            ]
          }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
            [
              GetBalanceQuery.Data.Address.Balance.self
            ]
          }

          /// Coin type for the balance, such as `0x2::sui::SUI`.
          var coinType: CoinType? { __data["coinType"] }
          /// The sum total of the accumulator balance and individual coin balances owned by the address.
          var totalBalance: SuiGraphQL.BigInt? { __data["totalBalance"] }

          /// Address.Balance.CoinType
          ///
          /// Parent Type: `MoveType`
          nonisolated struct CoinType: SuiGraphQL.SelectionSet {
            let __data: DataDict
            init(_dataDict: DataDict) { __data = _dataDict }

            static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.MoveType }
            static var __selections: [ApolloAPI.Selection] {
              [
                .field("__typename", String.self),
                .field("repr", String.self),
              ]
            }
            static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
              [
                GetBalanceQuery.Data.Address.Balance.CoinType.self
              ]
            }

            /// Flat representation of the type signature, as a displayable string.
            var repr: String { __data["repr"] }
          }
        }
      }
    }
  }

}
