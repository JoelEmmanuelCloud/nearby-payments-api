// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

extension SuiGraphQL {
  nonisolated struct ExecuteTransactionBlockMutation: GraphQLMutation {
    static let operationName: String = "executeTransactionBlock"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"mutation executeTransactionBlock($transactionDataBcs: Base64!, $signatures: [Base64!]!, $showBalanceChanges: Boolean = false, $showEffects: Boolean = false, $showRawEffects: Boolean = false, $showEvents: Boolean = false, $showInput: Boolean = false, $showObjectChanges: Boolean = false, $showRawInput: Boolean = false) { executeTransaction( transactionDataBcs: $transactionDataBcs signatures: $signatures ) { __typename effects { __typename effectsBcs @include(if: $showEffects) effectsBcs @include(if: $showRawEffects) events @include(if: $showEvents) { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename sender { __typename address } contents { __typename json } } } balanceChanges @include(if: $showBalanceChanges) { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename owner { __typename address } coinType { __typename repr } amount } } objectChanges @include(if: $showObjectChanges) { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename address inputState { __typename version } outputState { __typename version } } } transaction { __typename digest sender { __typename address } transactionBcs @include(if: $showInput) transactionBcs @include(if: $showRawInput) } status executionError { __typename message } } } }"#
      ))

    public var transactionDataBcs: Base64
    public var signatures: [Base64]
    public var showBalanceChanges: GraphQLNullable<Bool>
    public var showEffects: GraphQLNullable<Bool>
    public var showRawEffects: GraphQLNullable<Bool>
    public var showEvents: GraphQLNullable<Bool>
    public var showInput: GraphQLNullable<Bool>
    public var showObjectChanges: GraphQLNullable<Bool>
    public var showRawInput: GraphQLNullable<Bool>

    public init(
      transactionDataBcs: Base64,
      signatures: [Base64],
      showBalanceChanges: GraphQLNullable<Bool> = false,
      showEffects: GraphQLNullable<Bool> = false,
      showRawEffects: GraphQLNullable<Bool> = false,
      showEvents: GraphQLNullable<Bool> = false,
      showInput: GraphQLNullable<Bool> = false,
      showObjectChanges: GraphQLNullable<Bool> = false,
      showRawInput: GraphQLNullable<Bool> = false
    ) {
      self.transactionDataBcs = transactionDataBcs
      self.signatures = signatures
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
        "transactionDataBcs": transactionDataBcs,
        "signatures": signatures,
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

      static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Mutation }
      static var __selections: [ApolloAPI.Selection] {
        [
          .field(
            "executeTransaction", ExecuteTransaction.self,
            arguments: [
              "transactionDataBcs": .variable("transactionDataBcs"),
              "signatures": .variable("signatures"),
            ])
        ]
      }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
        [
          ExecuteTransactionBlockMutation.Data.self
        ]
      }

      /// Execute a transaction, committing its effects on chain.
      ///
      /// - `transactionDataBcs` contains the BCS-encoded transaction data (Base64-encoded).
      /// - `signatures` are a list of `flag || signature || pubkey` bytes, Base64-encoded.
      ///
      /// Waits until the transaction has reached finality on chain to return its transaction digest, or returns the error that prevented finality if that was not possible. A transaction is final when its effects are guaranteed on chain (it cannot be revoked).
      ///
      /// There may be a delay between transaction finality and when GraphQL requests (including the request that issued the transaction) reflect its effects. As a result, queries that depend on indexing the state of the chain (e.g. contents of output objects, address-level balance information at the time of the transaction), must wait for indexing to catch up by polling for the transaction digest using `Query.transaction`.
      var executeTransaction: ExecuteTransaction { __data["executeTransaction"] }

      /// ExecuteTransaction
      ///
      /// Parent Type: `ExecutionResult`
      nonisolated struct ExecuteTransaction: SuiGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.ExecutionResult }
        static var __selections: [ApolloAPI.Selection] {
          [
            .field("__typename", String.self),
            .field("effects", Effects?.self),
          ]
        }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
          [
            ExecuteTransactionBlockMutation.Data.ExecuteTransaction.self
          ]
        }

        /// The effects of the transaction execution.
        var effects: Effects? { __data["effects"] }

        /// ExecuteTransaction.Effects
        ///
        /// Parent Type: `TransactionEffects`
        nonisolated struct Effects: SuiGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType {
            SuiGraphQL.Objects.TransactionEffects
          }
          static var __selections: [ApolloAPI.Selection] {
            [
              .field("__typename", String.self),
              .field("transaction", Transaction?.self),
              .field("status", GraphQLEnum<SuiGraphQL.ExecutionStatus>?.self),
              .field("executionError", ExecutionError?.self),
              .include(
                if: "showEffects" || "showRawEffects", .field("effectsBcs", SuiGraphQL.Base64?.self)
              ),
              .include(if: "showEvents", .field("events", Events?.self)),
              .include(if: "showBalanceChanges", .field("balanceChanges", BalanceChanges?.self)),
              .include(if: "showObjectChanges", .field("objectChanges", ObjectChanges?.self)),
            ]
          }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
            [
              ExecuteTransactionBlockMutation.Data.ExecuteTransaction.Effects.self
            ]
          }

          /// The Base64-encoded BCS serialization of these effects, as `TransactionEffects`.
          var effectsBcs: SuiGraphQL.Base64? { __data["effectsBcs"] }
          /// Events emitted by this transaction.
          var events: Events? { __data["events"] }
          /// The effect this transaction had on the balances (sum of coin values per coin type) of addresses and objects.
          var balanceChanges: BalanceChanges? { __data["balanceChanges"] }
          /// The before and after state of objects that were modified by this transaction.
          var objectChanges: ObjectChanges? { __data["objectChanges"] }
          /// The transaction that ran to produce these effects.
          var transaction: Transaction? { __data["transaction"] }
          /// Whether the transaction executed successfully or not.
          var status: GraphQLEnum<SuiGraphQL.ExecutionStatus>? { __data["status"] }
          /// Rich execution error information for failed transactions.
          var executionError: ExecutionError? { __data["executionError"] }

          /// ExecuteTransaction.Effects.Events
          ///
          /// Parent Type: `EventConnection`
          nonisolated struct Events: SuiGraphQL.SelectionSet {
            let __data: DataDict
            init(_dataDict: DataDict) { __data = _dataDict }

            static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.EventConnection }
            static var __selections: [ApolloAPI.Selection] {
              [
                .field("__typename", String.self),
                .field("pageInfo", PageInfo.self),
                .field("nodes", [Node].self),
              ]
            }
            static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
              [
                ExecuteTransactionBlockMutation.Data.ExecuteTransaction.Effects.Events.self
              ]
            }

            /// Information to aid in pagination.
            var pageInfo: PageInfo { __data["pageInfo"] }
            /// A list of nodes.
            var nodes: [Node] { __data["nodes"] }

            /// ExecuteTransaction.Effects.Events.PageInfo
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
                  ExecuteTransactionBlockMutation.Data.ExecuteTransaction.Effects.Events.PageInfo
                    .self
                ]
              }

              /// When paginating forwards, are there more items?
              var hasNextPage: Bool { __data["hasNextPage"] }
              /// When paginating forwards, the cursor to continue.
              var endCursor: String? { __data["endCursor"] }
            }

            /// ExecuteTransaction.Effects.Events.Node
            ///
            /// Parent Type: `Event`
            nonisolated struct Node: SuiGraphQL.SelectionSet {
              let __data: DataDict
              init(_dataDict: DataDict) { __data = _dataDict }

              static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Event }
              static var __selections: [ApolloAPI.Selection] {
                [
                  .field("__typename", String.self),
                  .field("sender", Sender?.self),
                  .field("contents", Contents?.self),
                ]
              }
              static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
                [
                  ExecuteTransactionBlockMutation.Data.ExecuteTransaction.Effects.Events.Node.self
                ]
              }

              /// Address of the sender of the transaction that emitted this event.
              var sender: Sender? { __data["sender"] }
              /// The Move value emitted for this event.
              var contents: Contents? { __data["contents"] }

              /// ExecuteTransaction.Effects.Events.Node.Sender
              ///
              /// Parent Type: `Address`
              nonisolated struct Sender: SuiGraphQL.SelectionSet {
                let __data: DataDict
                init(_dataDict: DataDict) { __data = _dataDict }

                static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Address }
                static var __selections: [ApolloAPI.Selection] {
                  [
                    .field("__typename", String.self),
                    .field("address", SuiGraphQL.SuiAddress.self),
                  ]
                }
                static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
                  [
                    ExecuteTransactionBlockMutation.Data.ExecuteTransaction.Effects.Events.Node
                      .Sender.self
                  ]
                }

                /// The Address' identifier, a 32-byte number represented as a 64-character hex string, with a lead "0x".
                var address: SuiGraphQL.SuiAddress { __data["address"] }
              }

              /// ExecuteTransaction.Effects.Events.Node.Contents
              ///
              /// Parent Type: `MoveValue`
              nonisolated struct Contents: SuiGraphQL.SelectionSet {
                let __data: DataDict
                init(_dataDict: DataDict) { __data = _dataDict }

                static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.MoveValue }
                static var __selections: [ApolloAPI.Selection] {
                  [
                    .field("__typename", String.self),
                    .field("json", SuiGraphQL.JSON?.self),
                  ]
                }
                static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
                  [
                    ExecuteTransactionBlockMutation.Data.ExecuteTransaction.Effects.Events.Node
                      .Contents.self
                  ]
                }

                /// Representation of a Move value in JSON, where:
                ///
                /// - Addresses, IDs, and UIDs are represented in canonical form, as JSON strings.
                /// - Bools are represented by JSON boolean literals.
                /// - u8, u16, and u32 are represented as JSON numbers.
                /// - u64, u128, and u256 are represented as JSON strings.
                /// - Balances, Strings, and Urls are represented as JSON strings.
                /// - Vectors of bytes are represented as Base64 blobs, and other vectors are represented by JSON arrays.
                /// - Structs are represented by JSON objects.
                /// - Enums are represented by JSON objects, with a field named `@variant` containing the variant name.
                /// - Empty optional values are represented by `null`.
                var json: SuiGraphQL.JSON? { __data["json"] }
              }
            }
          }

          /// ExecuteTransaction.Effects.BalanceChanges
          ///
          /// Parent Type: `BalanceChangeConnection`
          nonisolated struct BalanceChanges: SuiGraphQL.SelectionSet {
            let __data: DataDict
            init(_dataDict: DataDict) { __data = _dataDict }

            static var __parentType: any ApolloAPI.ParentType {
              SuiGraphQL.Objects.BalanceChangeConnection
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
                ExecuteTransactionBlockMutation.Data.ExecuteTransaction.Effects.BalanceChanges.self
              ]
            }

            /// Information to aid in pagination.
            var pageInfo: PageInfo { __data["pageInfo"] }
            /// A list of nodes.
            var nodes: [Node] { __data["nodes"] }

            /// ExecuteTransaction.Effects.BalanceChanges.PageInfo
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
                  ExecuteTransactionBlockMutation.Data.ExecuteTransaction.Effects.BalanceChanges
                    .PageInfo.self
                ]
              }

              /// When paginating forwards, are there more items?
              var hasNextPage: Bool { __data["hasNextPage"] }
              /// When paginating forwards, the cursor to continue.
              var endCursor: String? { __data["endCursor"] }
            }

            /// ExecuteTransaction.Effects.BalanceChanges.Node
            ///
            /// Parent Type: `BalanceChange`
            nonisolated struct Node: SuiGraphQL.SelectionSet {
              let __data: DataDict
              init(_dataDict: DataDict) { __data = _dataDict }

              static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.BalanceChange }
              static var __selections: [ApolloAPI.Selection] {
                [
                  .field("__typename", String.self),
                  .field("owner", Owner?.self),
                  .field("coinType", CoinType?.self),
                  .field("amount", SuiGraphQL.BigInt?.self),
                ]
              }
              static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
                [
                  ExecuteTransactionBlockMutation.Data.ExecuteTransaction.Effects.BalanceChanges
                    .Node.self
                ]
              }

              /// The address or object whose balance has changed.
              var owner: Owner? { __data["owner"] }
              /// The inner type of the coin whose balance has changed (e.g. `0x2::sui::SUI`).
              var coinType: CoinType? { __data["coinType"] }
              /// The signed balance change.
              var amount: SuiGraphQL.BigInt? { __data["amount"] }

              /// ExecuteTransaction.Effects.BalanceChanges.Node.Owner
              ///
              /// Parent Type: `Address`
              nonisolated struct Owner: SuiGraphQL.SelectionSet {
                let __data: DataDict
                init(_dataDict: DataDict) { __data = _dataDict }

                static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Address }
                static var __selections: [ApolloAPI.Selection] {
                  [
                    .field("__typename", String.self),
                    .field("address", SuiGraphQL.SuiAddress.self),
                  ]
                }
                static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
                  [
                    ExecuteTransactionBlockMutation.Data.ExecuteTransaction.Effects.BalanceChanges
                      .Node.Owner.self
                  ]
                }

                /// The Address' identifier, a 32-byte number represented as a 64-character hex string, with a lead "0x".
                var address: SuiGraphQL.SuiAddress { __data["address"] }
              }

              /// ExecuteTransaction.Effects.BalanceChanges.Node.CoinType
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
                    ExecuteTransactionBlockMutation.Data.ExecuteTransaction.Effects.BalanceChanges
                      .Node.CoinType.self
                  ]
                }

                /// Flat representation of the type signature, as a displayable string.
                var repr: String { __data["repr"] }
              }
            }
          }

          /// ExecuteTransaction.Effects.ObjectChanges
          ///
          /// Parent Type: `ObjectChangeConnection`
          nonisolated struct ObjectChanges: SuiGraphQL.SelectionSet {
            let __data: DataDict
            init(_dataDict: DataDict) { __data = _dataDict }

            static var __parentType: any ApolloAPI.ParentType {
              SuiGraphQL.Objects.ObjectChangeConnection
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
                ExecuteTransactionBlockMutation.Data.ExecuteTransaction.Effects.ObjectChanges.self
              ]
            }

            /// Information to aid in pagination.
            var pageInfo: PageInfo { __data["pageInfo"] }
            /// A list of nodes.
            var nodes: [Node] { __data["nodes"] }

            /// ExecuteTransaction.Effects.ObjectChanges.PageInfo
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
                  ExecuteTransactionBlockMutation.Data.ExecuteTransaction.Effects.ObjectChanges
                    .PageInfo.self
                ]
              }

              /// When paginating forwards, are there more items?
              var hasNextPage: Bool { __data["hasNextPage"] }
              /// When paginating forwards, the cursor to continue.
              var endCursor: String? { __data["endCursor"] }
            }

            /// ExecuteTransaction.Effects.ObjectChanges.Node
            ///
            /// Parent Type: `ObjectChange`
            nonisolated struct Node: SuiGraphQL.SelectionSet {
              let __data: DataDict
              init(_dataDict: DataDict) { __data = _dataDict }

              static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.ObjectChange }
              static var __selections: [ApolloAPI.Selection] {
                [
                  .field("__typename", String.self),
                  .field("address", SuiGraphQL.SuiAddress.self),
                  .field("inputState", InputState?.self),
                  .field("outputState", OutputState?.self),
                ]
              }
              static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
                [
                  ExecuteTransactionBlockMutation.Data.ExecuteTransaction.Effects.ObjectChanges.Node
                    .self
                ]
              }

              /// The address of the object that has changed.
              var address: SuiGraphQL.SuiAddress { __data["address"] }
              /// The contents of the object immediately before the transaction.
              var inputState: InputState? { __data["inputState"] }
              /// The contents of the object immediately after the transaction.
              var outputState: OutputState? { __data["outputState"] }

              /// ExecuteTransaction.Effects.ObjectChanges.Node.InputState
              ///
              /// Parent Type: `Object`
              nonisolated struct InputState: SuiGraphQL.SelectionSet {
                let __data: DataDict
                init(_dataDict: DataDict) { __data = _dataDict }

                static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Object }
                static var __selections: [ApolloAPI.Selection] {
                  [
                    .field("__typename", String.self),
                    .field("version", SuiGraphQL.UInt53?.self),
                  ]
                }
                static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
                  [
                    ExecuteTransactionBlockMutation.Data.ExecuteTransaction.Effects.ObjectChanges
                      .Node.InputState.self
                  ]
                }

                /// The version of this object that this content comes from.
                var version: SuiGraphQL.UInt53? { __data["version"] }
              }

              /// ExecuteTransaction.Effects.ObjectChanges.Node.OutputState
              ///
              /// Parent Type: `Object`
              nonisolated struct OutputState: SuiGraphQL.SelectionSet {
                let __data: DataDict
                init(_dataDict: DataDict) { __data = _dataDict }

                static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Object }
                static var __selections: [ApolloAPI.Selection] {
                  [
                    .field("__typename", String.self),
                    .field("version", SuiGraphQL.UInt53?.self),
                  ]
                }
                static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
                  [
                    ExecuteTransactionBlockMutation.Data.ExecuteTransaction.Effects.ObjectChanges
                      .Node.OutputState.self
                  ]
                }

                /// The version of this object that this content comes from.
                var version: SuiGraphQL.UInt53? { __data["version"] }
              }
            }
          }

          /// ExecuteTransaction.Effects.Transaction
          ///
          /// Parent Type: `Transaction`
          nonisolated struct Transaction: SuiGraphQL.SelectionSet {
            let __data: DataDict
            init(_dataDict: DataDict) { __data = _dataDict }

            static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Transaction }
            static var __selections: [ApolloAPI.Selection] {
              [
                .field("__typename", String.self),
                .field("digest", String.self),
                .field("sender", Sender?.self),
                .include(
                  if: "showInput" || "showRawInput",
                  .field("transactionBcs", SuiGraphQL.Base64?.self)),
              ]
            }
            static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
              [
                ExecuteTransactionBlockMutation.Data.ExecuteTransaction.Effects.Transaction.self
              ]
            }

            /// A 32-byte hash that uniquely identifies the transaction contents, encoded in Base58.
            var digest: String { __data["digest"] }
            /// The address corresponding to the public key that signed this transaction. System transactions do not have senders.
            var sender: Sender? { __data["sender"] }
            /// The Base64-encoded BCS serialization of this transaction, as a `TransactionData`.
            var transactionBcs: SuiGraphQL.Base64? { __data["transactionBcs"] }

            /// ExecuteTransaction.Effects.Transaction.Sender
            ///
            /// Parent Type: `Address`
            nonisolated struct Sender: SuiGraphQL.SelectionSet {
              let __data: DataDict
              init(_dataDict: DataDict) { __data = _dataDict }

              static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Address }
              static var __selections: [ApolloAPI.Selection] {
                [
                  .field("__typename", String.self),
                  .field("address", SuiGraphQL.SuiAddress.self),
                ]
              }
              static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
                [
                  ExecuteTransactionBlockMutation.Data.ExecuteTransaction.Effects.Transaction.Sender
                    .self
                ]
              }

              /// The Address' identifier, a 32-byte number represented as a 64-character hex string, with a lead "0x".
              var address: SuiGraphQL.SuiAddress { __data["address"] }
            }
          }

          /// ExecuteTransaction.Effects.ExecutionError
          ///
          /// Parent Type: `ExecutionError`
          nonisolated struct ExecutionError: SuiGraphQL.SelectionSet {
            let __data: DataDict
            init(_dataDict: DataDict) { __data = _dataDict }

            static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.ExecutionError }
            static var __selections: [ApolloAPI.Selection] {
              [
                .field("__typename", String.self),
                .field("message", String.self),
              ]
            }
            static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
              [
                ExecuteTransactionBlockMutation.Data.ExecuteTransaction.Effects.ExecutionError.self
              ]
            }

            /// Human readable explanation of why the transaction failed.
            ///
            /// For Move aborts, the error message will be resolved to a human-readable form if possible, otherwise it will fall back to displaying the abort code and location.
            var message: String { __data["message"] }
          }
        }
      }
    }
  }

}
