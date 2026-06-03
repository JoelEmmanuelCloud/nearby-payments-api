// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

extension SuiGraphQL {
  nonisolated struct QueryTransactionBlocksQuery: GraphQLQuery {
    static let operationName: String = "queryTransactionBlocks"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query queryTransactionBlocks($first: Int, $last: Int, $before: String, $after: String, $showBalanceChanges: Boolean = false, $showEffects: Boolean = false, $showRawEffects: Boolean = false, $showEvents: Boolean = false, $showInput: Boolean = false, $showObjectChanges: Boolean = false, $showRawInput: Boolean = false, $filter: TransactionFilter) { transactions( first: $first after: $after last: $last before: $before filter: $filter ) { __typename pageInfo { __typename hasNextPage hasPreviousPage startCursor endCursor } nodes { __typename ...RPC_TRANSACTION_FIELDS } } }"#,
        fragments: [RPC_EVENTS_FIELDS.self, RPC_TRANSACTION_FIELDS.self]
      ))

    public var first: GraphQLNullable<Int32>
    public var last: GraphQLNullable<Int32>
    public var before: GraphQLNullable<String>
    public var after: GraphQLNullable<String>
    public var showBalanceChanges: GraphQLNullable<Bool>
    public var showEffects: GraphQLNullable<Bool>
    public var showRawEffects: GraphQLNullable<Bool>
    public var showEvents: GraphQLNullable<Bool>
    public var showInput: GraphQLNullable<Bool>
    public var showObjectChanges: GraphQLNullable<Bool>
    public var showRawInput: GraphQLNullable<Bool>
    public var filter: GraphQLNullable<TransactionFilter>

    public init(
      first: GraphQLNullable<Int32>,
      last: GraphQLNullable<Int32>,
      before: GraphQLNullable<String>,
      after: GraphQLNullable<String>,
      showBalanceChanges: GraphQLNullable<Bool> = false,
      showEffects: GraphQLNullable<Bool> = false,
      showRawEffects: GraphQLNullable<Bool> = false,
      showEvents: GraphQLNullable<Bool> = false,
      showInput: GraphQLNullable<Bool> = false,
      showObjectChanges: GraphQLNullable<Bool> = false,
      showRawInput: GraphQLNullable<Bool> = false,
      filter: GraphQLNullable<TransactionFilter>
    ) {
      self.first = first
      self.last = last
      self.before = before
      self.after = after
      self.showBalanceChanges = showBalanceChanges
      self.showEffects = showEffects
      self.showRawEffects = showRawEffects
      self.showEvents = showEvents
      self.showInput = showInput
      self.showObjectChanges = showObjectChanges
      self.showRawInput = showRawInput
      self.filter = filter
    }

    @_spi(Unsafe) public var __variables: Variables? {
      [
        "first": first,
        "last": last,
        "before": before,
        "after": after,
        "showBalanceChanges": showBalanceChanges,
        "showEffects": showEffects,
        "showRawEffects": showRawEffects,
        "showEvents": showEvents,
        "showInput": showInput,
        "showObjectChanges": showObjectChanges,
        "showRawInput": showRawInput,
        "filter": filter,
      ]
    }

    nonisolated struct Data: SuiGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Query }
      static var __selections: [ApolloAPI.Selection] {
        [
          .field(
            "transactions", Transactions?.self,
            arguments: [
              "first": .variable("first"),
              "after": .variable("after"),
              "last": .variable("last"),
              "before": .variable("before"),
              "filter": .variable("filter"),
            ])
        ]
      }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
        [
          QueryTransactionBlocksQuery.Data.self
        ]
      }

      /// The transactions that exist in the network, optionally filtered by transaction filters.
      var transactions: Transactions? { __data["transactions"] }

      /// Transactions
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
            QueryTransactionBlocksQuery.Data.Transactions.self
          ]
        }

        /// Information to aid in pagination.
        var pageInfo: PageInfo { __data["pageInfo"] }
        /// A list of nodes.
        var nodes: [Node] { __data["nodes"] }

        /// Transactions.PageInfo
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
              .field("hasPreviousPage", Bool.self),
              .field("startCursor", String?.self),
              .field("endCursor", String?.self),
            ]
          }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
            [
              QueryTransactionBlocksQuery.Data.Transactions.PageInfo.self
            ]
          }

          /// When paginating forwards, are there more items?
          var hasNextPage: Bool { __data["hasNextPage"] }
          /// When paginating backwards, are there more items?
          var hasPreviousPage: Bool { __data["hasPreviousPage"] }
          /// When paginating backwards, the cursor to continue.
          var startCursor: String? { __data["startCursor"] }
          /// When paginating forwards, the cursor to continue.
          var endCursor: String? { __data["endCursor"] }
        }

        /// Transactions.Node
        ///
        /// Parent Type: `Transaction`
        nonisolated struct Node: SuiGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Transaction }
          static var __selections: [ApolloAPI.Selection] {
            [
              .field("__typename", String.self),
              .fragment(RPC_TRANSACTION_FIELDS.self),
            ]
          }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
            [
              QueryTransactionBlocksQuery.Data.Transactions.Node.self,
              RPC_TRANSACTION_FIELDS.self,
            ]
          }

          /// A 32-byte hash that uniquely identifies the transaction contents, encoded in Base58.
          var digest: String { __data["digest"] }
          /// The Base64-encoded BCS serialization of this transaction, as a `TransactionData`.
          var rawTransaction: SuiGraphQL.Base64? { __data["rawTransaction"] }
          /// The address corresponding to the public key that signed this transaction. System transactions do not have senders.
          var sender: Sender? { __data["sender"] }
          /// User signatures for this transaction.
          var signatures: [Signature] { __data["signatures"] }
          /// The results to the chain of executing this transaction.
          var effects: Effects? { __data["effects"] }

          struct Fragments: FragmentContainer {
            let __data: DataDict
            init(_dataDict: DataDict) { __data = _dataDict }

            var rPC_TRANSACTION_FIELDS: RPC_TRANSACTION_FIELDS { _toFragment() }
          }

          typealias Sender = RPC_TRANSACTION_FIELDS.Sender

          typealias Signature = RPC_TRANSACTION_FIELDS.Signature

          typealias Effects = RPC_TRANSACTION_FIELDS.Effects
        }
      }
    }
  }

}
