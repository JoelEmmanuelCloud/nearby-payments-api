// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

extension SuiGraphQL {
  nonisolated struct PaginateTransactionBlockListsQuery: GraphQLQuery {
    static let operationName: String = "paginateTransactionBlockLists"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query paginateTransactionBlockLists($digest: String!, $hasMoreEvents: Boolean!, $hasMoreBalanceChanges: Boolean!, $hasMoreObjectChanges: Boolean!, $afterEvents: String, $afterBalanceChanges: String, $afterObjectChanges: String) { transaction(digest: $digest) { __typename ...PAGINATE_TRANSACTION_LISTS } }"#,
        fragments: [PAGINATE_TRANSACTION_LISTS.self, RPC_EVENTS_FIELDS.self]
      ))

    public var digest: String
    public var hasMoreEvents: Bool
    public var hasMoreBalanceChanges: Bool
    public var hasMoreObjectChanges: Bool
    public var afterEvents: GraphQLNullable<String>
    public var afterBalanceChanges: GraphQLNullable<String>
    public var afterObjectChanges: GraphQLNullable<String>

    public init(
      digest: String,
      hasMoreEvents: Bool,
      hasMoreBalanceChanges: Bool,
      hasMoreObjectChanges: Bool,
      afterEvents: GraphQLNullable<String>,
      afterBalanceChanges: GraphQLNullable<String>,
      afterObjectChanges: GraphQLNullable<String>
    ) {
      self.digest = digest
      self.hasMoreEvents = hasMoreEvents
      self.hasMoreBalanceChanges = hasMoreBalanceChanges
      self.hasMoreObjectChanges = hasMoreObjectChanges
      self.afterEvents = afterEvents
      self.afterBalanceChanges = afterBalanceChanges
      self.afterObjectChanges = afterObjectChanges
    }

    @_spi(Unsafe) public var __variables: Variables? {
      [
        "digest": digest,
        "hasMoreEvents": hasMoreEvents,
        "hasMoreBalanceChanges": hasMoreBalanceChanges,
        "hasMoreObjectChanges": hasMoreObjectChanges,
        "afterEvents": afterEvents,
        "afterBalanceChanges": afterBalanceChanges,
        "afterObjectChanges": afterObjectChanges,
      ]
    }

    nonisolated struct Data: SuiGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Query }
      static var __selections: [ApolloAPI.Selection] {
        [
          .field("transaction", Transaction?.self, arguments: ["digest": .variable("digest")])
        ]
      }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
        [
          PaginateTransactionBlockListsQuery.Data.self
        ]
      }

      /// Fetch a transaction by its digest.
      ///
      /// Returns `null` if the transaction does not exist in the store, either because it never existed or because it was pruned.
      var transaction: Transaction? { __data["transaction"] }

      /// Transaction
      ///
      /// Parent Type: `Transaction`
      nonisolated struct Transaction: SuiGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Transaction }
        static var __selections: [ApolloAPI.Selection] {
          [
            .field("__typename", String.self),
            .fragment(PAGINATE_TRANSACTION_LISTS.self),
          ]
        }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
          [
            PaginateTransactionBlockListsQuery.Data.Transaction.self,
            PAGINATE_TRANSACTION_LISTS.self,
          ]
        }

        /// The results to the chain of executing this transaction.
        var effects: Effects? { __data["effects"] }

        struct Fragments: FragmentContainer {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          var pAGINATE_TRANSACTION_LISTS: PAGINATE_TRANSACTION_LISTS { _toFragment() }
        }

        typealias Effects = PAGINATE_TRANSACTION_LISTS.Effects
      }
    }
  }

}
