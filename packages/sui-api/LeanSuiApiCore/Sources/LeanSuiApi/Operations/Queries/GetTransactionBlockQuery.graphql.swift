// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

extension SuiGraphQL {
  nonisolated struct GetTransactionBlockQuery: GraphQLQuery {
    static let operationName: String = "getTransactionBlock"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query getTransactionBlock($digest: String!, $showBalanceChanges: Boolean = false, $showEffects: Boolean = false, $showRawEffects: Boolean = false, $showEvents: Boolean = false, $showInput: Boolean = false, $showObjectChanges: Boolean = false, $showRawInput: Boolean = false) { transaction(digest: $digest) { __typename ...RPC_TRANSACTION_FIELDS } }"#,
        fragments: [RPC_EVENTS_FIELDS.self, RPC_TRANSACTION_FIELDS.self]
      ))

    public var digest: String
    public var showBalanceChanges: GraphQLNullable<Bool>
    public var showEffects: GraphQLNullable<Bool>
    public var showRawEffects: GraphQLNullable<Bool>
    public var showEvents: GraphQLNullable<Bool>
    public var showInput: GraphQLNullable<Bool>
    public var showObjectChanges: GraphQLNullable<Bool>
    public var showRawInput: GraphQLNullable<Bool>

    public init(
      digest: String,
      showBalanceChanges: GraphQLNullable<Bool> = false,
      showEffects: GraphQLNullable<Bool> = false,
      showRawEffects: GraphQLNullable<Bool> = false,
      showEvents: GraphQLNullable<Bool> = false,
      showInput: GraphQLNullable<Bool> = false,
      showObjectChanges: GraphQLNullable<Bool> = false,
      showRawInput: GraphQLNullable<Bool> = false
    ) {
      self.digest = digest
      self.showBalanceChanges = showBalanceChanges
      self.showEffects = showEffects
      self.showRawEffects = showRawEffects
      self.showEvents = showEvents
      self.showInput = showInput
      self.showObjectChanges = showObjectChanges
      self.showRawInput = showRawInput
    }

    @_spi(Unsafe) public var __variables: Variables? {
      [
        "digest": digest,
        "showBalanceChanges": showBalanceChanges,
        "showEffects": showEffects,
        "showRawEffects": showRawEffects,
        "showEvents": showEvents,
        "showInput": showInput,
        "showObjectChanges": showObjectChanges,
        "showRawInput": showRawInput,
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
          GetTransactionBlockQuery.Data.self
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
            .fragment(RPC_TRANSACTION_FIELDS.self),
          ]
        }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
          [
            GetTransactionBlockQuery.Data.Transaction.self,
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
