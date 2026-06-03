// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

extension SuiGraphQL {
  nonisolated struct PaginateCheckpointTransactionBlocksQuery: GraphQLQuery {
    static let operationName: String = "paginateCheckpointTransactionBlocks"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query paginateCheckpointTransactionBlocks($sequenceNumber: UInt53, $after: String) { checkpoint(sequenceNumber: $sequenceNumber) { __typename transactions(after: $after) { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename digest } } } }"#
      ))

    public var sequenceNumber: GraphQLNullable<UInt53>
    public var after: GraphQLNullable<String>

    public init(
      sequenceNumber: GraphQLNullable<UInt53>,
      after: GraphQLNullable<String>
    ) {
      self.sequenceNumber = sequenceNumber
      self.after = after
    }

    @_spi(Unsafe) public var __variables: Variables? {
      [
        "sequenceNumber": sequenceNumber,
        "after": after,
      ]
    }

    nonisolated struct Data: SuiGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Query }
      static var __selections: [ApolloAPI.Selection] {
        [
          .field(
            "checkpoint", Checkpoint?.self,
            arguments: ["sequenceNumber": .variable("sequenceNumber")])
        ]
      }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
        [
          PaginateCheckpointTransactionBlocksQuery.Data.self
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
            .field("transactions", Transactions?.self, arguments: ["after": .variable("after")]),
          ]
        }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
          [
            PaginateCheckpointTransactionBlocksQuery.Data.Checkpoint.self
          ]
        }

        var transactions: Transactions? { __data["transactions"] }

        /// Checkpoint.Transactions
        ///
        /// Parent Type: `TransactionConnection`
        nonisolated struct Transactions: SuiGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType {
            SuiGraphQL.Objects.TransactionConnection
          }
          static var __selections: [ApolloAPI.Selection] {
            [
              .field("__typename", String.self),
              .field("pageInfo", PageInfo.self),
              .field("nodes", [Node].self),
            ]
          }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
            [
              PaginateCheckpointTransactionBlocksQuery.Data.Checkpoint.Transactions.self
            ]
          }

          /// Information to aid in pagination.
          var pageInfo: PageInfo { __data["pageInfo"] }
          /// A list of nodes.
          var nodes: [Node] { __data["nodes"] }

          /// Checkpoint.Transactions.PageInfo
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
                PaginateCheckpointTransactionBlocksQuery.Data.Checkpoint.Transactions.PageInfo.self
              ]
            }

            /// When paginating forwards, are there more items?
            var hasNextPage: Bool { __data["hasNextPage"] }
            /// When paginating forwards, the cursor to continue.
            var endCursor: String? { __data["endCursor"] }
          }

          /// Checkpoint.Transactions.Node
          ///
          /// Parent Type: `Transaction`
          nonisolated struct Node: SuiGraphQL.SelectionSet {
            let __data: DataDict
            init(_dataDict: DataDict) { __data = _dataDict }

            static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Transaction }
            static var __selections: [ApolloAPI.Selection] {
              [
                .field("__typename", String.self),
                .field("digest", String.self),
              ]
            }
            static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
              [
                PaginateCheckpointTransactionBlocksQuery.Data.Checkpoint.Transactions.Node.self
              ]
            }

            /// A 32-byte hash that uniquely identifies the transaction contents, encoded in Base58.
            var digest: String { __data["digest"] }
          }
        }
      }
    }
  }

}
