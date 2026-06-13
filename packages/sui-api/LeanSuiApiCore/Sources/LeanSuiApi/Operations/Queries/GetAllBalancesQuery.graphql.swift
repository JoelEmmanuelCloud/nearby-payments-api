// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

extension SuiGraphQL {
  nonisolated struct GetAllBalancesQuery: GraphQLQuery {
    static let operationName: String = "getAllBalances"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query getAllBalances($owner: SuiAddress!, $limit: Int, $cursor: String) { address(address: $owner) { __typename balances(first: $limit, after: $cursor) { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename coinType { __typename repr } totalBalance } } } }"#
      ))

    public var owner: SuiAddress
    public var limit: GraphQLNullable<Int32>
    public var cursor: GraphQLNullable<String>

    public init(
      owner: SuiAddress,
      limit: GraphQLNullable<Int32>,
      cursor: GraphQLNullable<String>
    ) {
      self.owner = owner
      self.limit = limit
      self.cursor = cursor
    }

    @_spi(Unsafe) public var __variables: Variables? {
      [
        "owner": owner,
        "limit": limit,
        "cursor": cursor,
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
          GetAllBalancesQuery.Data.self
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
            .field(
              "balances", Balances?.self,
              arguments: [
                "first": .variable("limit"),
                "after": .variable("cursor"),
              ]),
          ]
        }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
          [
            GetAllBalancesQuery.Data.Address.self
          ]
        }

        /// Total balance across coins owned by this address, grouped by coin type.
        var balances: Balances? { __data["balances"] }

        /// Address.Balances
        ///
        /// Parent Type: `BalanceConnection`
        nonisolated struct Balances: SuiGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.BalanceConnection }
          static var __selections: [ApolloAPI.Selection] {
            [
              .field("__typename", String.self),
              .field("pageInfo", PageInfo.self),
              .field("nodes", [Node].self),
            ]
          }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
            [
              GetAllBalancesQuery.Data.Address.Balances.self
            ]
          }

          /// Information to aid in pagination.
          var pageInfo: PageInfo { __data["pageInfo"] }
          /// A list of nodes.
          var nodes: [Node] { __data["nodes"] }

          /// Address.Balances.PageInfo
          ///
          /// Parent Type: `PageInfo`
          nonisolated struct PageInfo: SuiGraphQL.SelectionSet {
            let __data: DataDict
            init(_dataDict: DataDict) { __data = _dataDict }

            static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.PageInfo }
            static var __selections: [ApolloAPI.Selection] {
              [
                .field("__typename", String.self),
                .field("hasNextPage", Bool.self),
                .field("endCursor", String?.self),
              ]
            }
            static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
              [
                GetAllBalancesQuery.Data.Address.Balances.PageInfo.self
              ]
            }

            /// When paginating forwards, are there more items?
            var hasNextPage: Bool { __data["hasNextPage"] }
            /// When paginating forwards, the cursor to continue.
            var endCursor: String? { __data["endCursor"] }
          }

          /// Address.Balances.Node
          ///
          /// Parent Type: `Balance`
          nonisolated struct Node: SuiGraphQL.SelectionSet {
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
                GetAllBalancesQuery.Data.Address.Balances.Node.self
              ]
            }

            /// Coin type for the balance, such as `0x2::sui::SUI`.
            var coinType: CoinType? { __data["coinType"] }
            /// The sum total of the accumulator balance and individual coin balances owned by the address.
            var totalBalance: SuiGraphQL.BigInt? { __data["totalBalance"] }

            /// Address.Balances.Node.CoinType
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
                  GetAllBalancesQuery.Data.Address.Balances.Node.CoinType.self
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

}
