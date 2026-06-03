// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

extension SuiGraphQL {
  nonisolated struct DryRunTransactionBlockQuery: GraphQLQuery {
    static let operationName: String = "dryRunTransactionBlock"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query dryRunTransactionBlock($transaction: JSON!, $showBalanceChanges: Boolean = false, $showEffects: Boolean = false, $showRawEffects: Boolean = false, $showEvents: Boolean = false, $showObjectChanges: Boolean = false) { simulateTransaction(transaction: $transaction) { __typename effects { __typename effectsBcs @include(if: $showEffects) effectsBcs @include(if: $showRawEffects) balanceChanges @include(if: $showBalanceChanges) { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename owner { __typename address } coinType { __typename repr } amount } } objectChanges @include(if: $showObjectChanges) { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename address inputState { __typename version } outputState { __typename version } } } status executionError { __typename message } gasEffects { __typename gasSummary { __typename computationCost storageCost storageRebate nonRefundableStorageFee } } events @include(if: $showEvents) { __typename nodes { __typename sender { __typename address } contents { __typename json bcs } timestamp } } } } }"#
      ))

    public var transaction: JSON
    public var showBalanceChanges: GraphQLNullable<Bool>
    public var showEffects: GraphQLNullable<Bool>
    public var showRawEffects: GraphQLNullable<Bool>
    public var showEvents: GraphQLNullable<Bool>
    public var showObjectChanges: GraphQLNullable<Bool>

    public init(
      transaction: JSON,
      showBalanceChanges: GraphQLNullable<Bool> = false,
      showEffects: GraphQLNullable<Bool> = false,
      showRawEffects: GraphQLNullable<Bool> = false,
      showEvents: GraphQLNullable<Bool> = false,
      showObjectChanges: GraphQLNullable<Bool> = false
    ) {
      self.transaction = transaction
      self.showBalanceChanges = showBalanceChanges
      self.showEffects = showEffects
      self.showRawEffects = showRawEffects
      self.showEvents = showEvents
      self.showObjectChanges = showObjectChanges
    }

    @_spi(Unsafe) public var __variables: Variables? {
      [
        "transaction": transaction,
        "showBalanceChanges": showBalanceChanges,
        "showEffects": showEffects,
        "showRawEffects": showRawEffects,
        "showEvents": showEvents,
        "showObjectChanges": showObjectChanges,
      ]
    }

    nonisolated struct Data: SuiGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Query }
      static var __selections: [ApolloAPI.Selection] {
        [
          .field(
            "simulateTransaction", SimulateTransaction.self,
            arguments: ["transaction": .variable("transaction")])
        ]
      }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
        [
          DryRunTransactionBlockQuery.Data.self
        ]
      }

      /// Simulate a transaction to preview its effects without executing it on chain.
      ///
      /// Accepts a JSON transaction matching the [Sui gRPC API schema](https://docs.sui.io/references/fullnode-protocol#sui-rpc-v2-Transaction).
      /// The JSON format allows for partial transaction specification where certain fields can be automatically resolved by the server.
      ///
      /// Alternatively, for already serialized transactions, you can pass BCS-encoded data:
      /// `{"bcs": {"value": "<base64>"}}`
      ///
      /// Unlike `executeTransaction`, this does not require signatures since the transaction is not committed to the blockchain. This allows for previewing transaction effects, estimating gas costs, and testing transaction logic without spending gas or requiring valid signatures.
      ///
      /// - `checksEnabled`: If true, enables transaction validation checks during simulation. Defaults to true.
      /// - `doGasSelection`: If true, enables automatic gas coin selection and budget estimation. Defaults to false.
      var simulateTransaction: SimulateTransaction { __data["simulateTransaction"] }

      /// SimulateTransaction
      ///
      /// Parent Type: `SimulationResult`
      nonisolated struct SimulateTransaction: SuiGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.SimulationResult }
        static var __selections: [ApolloAPI.Selection] {
          [
            .field("__typename", String.self),
            .field("effects", Effects?.self),
          ]
        }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
          [
            DryRunTransactionBlockQuery.Data.SimulateTransaction.self
          ]
        }

        /// The predicted effects of the transaction if it were executed.
        var effects: Effects? { __data["effects"] }

        /// SimulateTransaction.Effects
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
              .field("status", GraphQLEnum<SuiGraphQL.ExecutionStatus>?.self),
              .field("executionError", ExecutionError?.self),
              .field("gasEffects", GasEffects?.self),
              .include(
                if: "showEffects" || "showRawEffects", .field("effectsBcs", SuiGraphQL.Base64?.self)
              ),
              .include(if: "showBalanceChanges", .field("balanceChanges", BalanceChanges?.self)),
              .include(if: "showObjectChanges", .field("objectChanges", ObjectChanges?.self)),
              .include(if: "showEvents", .field("events", Events?.self)),
            ]
          }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
            [
              DryRunTransactionBlockQuery.Data.SimulateTransaction.Effects.self
            ]
          }

          /// The Base64-encoded BCS serialization of these effects, as `TransactionEffects`.
          var effectsBcs: SuiGraphQL.Base64? { __data["effectsBcs"] }
          /// The effect this transaction had on the balances (sum of coin values per coin type) of addresses and objects.
          var balanceChanges: BalanceChanges? { __data["balanceChanges"] }
          /// The before and after state of objects that were modified by this transaction.
          var objectChanges: ObjectChanges? { __data["objectChanges"] }
          /// Whether the transaction executed successfully or not.
          var status: GraphQLEnum<SuiGraphQL.ExecutionStatus>? { __data["status"] }
          /// Rich execution error information for failed transactions.
          var executionError: ExecutionError? { __data["executionError"] }
          /// Effects related to the gas object used for the transaction (costs incurred and the identity of the smashed gas object returned).
          var gasEffects: GasEffects? { __data["gasEffects"] }
          /// Events emitted by this transaction.
          var events: Events? { __data["events"] }

          /// SimulateTransaction.Effects.BalanceChanges
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
                DryRunTransactionBlockQuery.Data.SimulateTransaction.Effects.BalanceChanges.self
              ]
            }

            /// Information to aid in pagination.
            var pageInfo: PageInfo { __data["pageInfo"] }
            /// A list of nodes.
            var nodes: [Node] { __data["nodes"] }

            /// SimulateTransaction.Effects.BalanceChanges.PageInfo
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
                  DryRunTransactionBlockQuery.Data.SimulateTransaction.Effects.BalanceChanges
                    .PageInfo.self
                ]
              }

              /// When paginating forwards, are there more items?
              var hasNextPage: Bool { __data["hasNextPage"] }
              /// When paginating forwards, the cursor to continue.
              var endCursor: String? { __data["endCursor"] }
            }

            /// SimulateTransaction.Effects.BalanceChanges.Node
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
                  DryRunTransactionBlockQuery.Data.SimulateTransaction.Effects.BalanceChanges.Node
                    .self
                ]
              }

              /// The address or object whose balance has changed.
              var owner: Owner? { __data["owner"] }
              /// The inner type of the coin whose balance has changed (e.g. `0x2::sui::SUI`).
              var coinType: CoinType? { __data["coinType"] }
              /// The signed balance change.
              var amount: SuiGraphQL.BigInt? { __data["amount"] }

              /// SimulateTransaction.Effects.BalanceChanges.Node.Owner
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
                    DryRunTransactionBlockQuery.Data.SimulateTransaction.Effects.BalanceChanges.Node
                      .Owner.self
                  ]
                }

                /// The Address' identifier, a 32-byte number represented as a 64-character hex string, with a lead "0x".
                var address: SuiGraphQL.SuiAddress { __data["address"] }
              }

              /// SimulateTransaction.Effects.BalanceChanges.Node.CoinType
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
                    DryRunTransactionBlockQuery.Data.SimulateTransaction.Effects.BalanceChanges.Node
                      .CoinType.self
                  ]
                }

                /// Flat representation of the type signature, as a displayable string.
                var repr: String { __data["repr"] }
              }
            }
          }

          /// SimulateTransaction.Effects.ObjectChanges
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
                DryRunTransactionBlockQuery.Data.SimulateTransaction.Effects.ObjectChanges.self
              ]
            }

            /// Information to aid in pagination.
            var pageInfo: PageInfo { __data["pageInfo"] }
            /// A list of nodes.
            var nodes: [Node] { __data["nodes"] }

            /// SimulateTransaction.Effects.ObjectChanges.PageInfo
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
                  DryRunTransactionBlockQuery.Data.SimulateTransaction.Effects.ObjectChanges
                    .PageInfo.self
                ]
              }

              /// When paginating forwards, are there more items?
              var hasNextPage: Bool { __data["hasNextPage"] }
              /// When paginating forwards, the cursor to continue.
              var endCursor: String? { __data["endCursor"] }
            }

            /// SimulateTransaction.Effects.ObjectChanges.Node
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
                  DryRunTransactionBlockQuery.Data.SimulateTransaction.Effects.ObjectChanges.Node
                    .self
                ]
              }

              /// The address of the object that has changed.
              var address: SuiGraphQL.SuiAddress { __data["address"] }
              /// The contents of the object immediately before the transaction.
              var inputState: InputState? { __data["inputState"] }
              /// The contents of the object immediately after the transaction.
              var outputState: OutputState? { __data["outputState"] }

              /// SimulateTransaction.Effects.ObjectChanges.Node.InputState
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
                    DryRunTransactionBlockQuery.Data.SimulateTransaction.Effects.ObjectChanges.Node
                      .InputState.self
                  ]
                }

                /// The version of this object that this content comes from.
                var version: SuiGraphQL.UInt53? { __data["version"] }
              }

              /// SimulateTransaction.Effects.ObjectChanges.Node.OutputState
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
                    DryRunTransactionBlockQuery.Data.SimulateTransaction.Effects.ObjectChanges.Node
                      .OutputState.self
                  ]
                }

                /// The version of this object that this content comes from.
                var version: SuiGraphQL.UInt53? { __data["version"] }
              }
            }
          }

          /// SimulateTransaction.Effects.ExecutionError
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
                DryRunTransactionBlockQuery.Data.SimulateTransaction.Effects.ExecutionError.self
              ]
            }

            /// Human readable explanation of why the transaction failed.
            ///
            /// For Move aborts, the error message will be resolved to a human-readable form if possible, otherwise it will fall back to displaying the abort code and location.
            var message: String { __data["message"] }
          }

          /// SimulateTransaction.Effects.GasEffects
          ///
          /// Parent Type: `GasEffects`
          nonisolated struct GasEffects: SuiGraphQL.SelectionSet {
            let __data: DataDict
            init(_dataDict: DataDict) { __data = _dataDict }

            static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.GasEffects }
            static var __selections: [ApolloAPI.Selection] {
              [
                .field("__typename", String.self),
                .field("gasSummary", GasSummary?.self),
              ]
            }
            static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
              [
                DryRunTransactionBlockQuery.Data.SimulateTransaction.Effects.GasEffects.self
              ]
            }

            /// Breakdown of the gas costs for this transaction.
            var gasSummary: GasSummary? { __data["gasSummary"] }

            /// SimulateTransaction.Effects.GasEffects.GasSummary
            ///
            /// Parent Type: `GasCostSummary`
            nonisolated struct GasSummary: SuiGraphQL.SelectionSet {
              let __data: DataDict
              init(_dataDict: DataDict) { __data = _dataDict }

              static var __parentType: any ApolloAPI.ParentType {
                SuiGraphQL.Objects.GasCostSummary
              }
              static var __selections: [ApolloAPI.Selection] {
                [
                  .field("__typename", String.self),
                  .field("computationCost", SuiGraphQL.UInt53?.self),
                  .field("storageCost", SuiGraphQL.UInt53?.self),
                  .field("storageRebate", SuiGraphQL.UInt53?.self),
                  .field("nonRefundableStorageFee", SuiGraphQL.UInt53?.self),
                ]
              }
              static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
                [
                  DryRunTransactionBlockQuery.Data.SimulateTransaction.Effects.GasEffects.GasSummary
                    .self
                ]
              }

              /// The sum cost of computation/execution
              var computationCost: SuiGraphQL.UInt53? { __data["computationCost"] }
              /// Cost for storage at the time the transaction is executed, calculated as the size of the objects being mutated in bytes multiplied by a storage cost per byte (part of the protocol).
              var storageCost: SuiGraphQL.UInt53? { __data["storageCost"] }
              /// Amount the user gets back from the storage cost of the previous versions of objects being mutated or deleted.
              var storageRebate: SuiGraphQL.UInt53? { __data["storageRebate"] }
              /// Amount that is retained by the system in the storage fund from the cost of the previous versions of objects being mutated or deleted.
              var nonRefundableStorageFee: SuiGraphQL.UInt53? { __data["nonRefundableStorageFee"] }
            }
          }

          /// SimulateTransaction.Effects.Events
          ///
          /// Parent Type: `EventConnection`
          nonisolated struct Events: SuiGraphQL.SelectionSet {
            let __data: DataDict
            init(_dataDict: DataDict) { __data = _dataDict }

            static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.EventConnection }
            static var __selections: [ApolloAPI.Selection] {
              [
                .field("__typename", String.self),
                .field("nodes", [Node].self),
              ]
            }
            static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
              [
                DryRunTransactionBlockQuery.Data.SimulateTransaction.Effects.Events.self
              ]
            }

            /// A list of nodes.
            var nodes: [Node] { __data["nodes"] }

            /// SimulateTransaction.Effects.Events.Node
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
                  .field("timestamp", SuiGraphQL.DateTime?.self),
                ]
              }
              static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
                [
                  DryRunTransactionBlockQuery.Data.SimulateTransaction.Effects.Events.Node.self
                ]
              }

              /// Address of the sender of the transaction that emitted this event.
              var sender: Sender? { __data["sender"] }
              /// The Move value emitted for this event.
              var contents: Contents? { __data["contents"] }
              /// Timestamp corresponding to the checkpoint this event's transaction was finalized in.
              /// All events from the same transaction share the same timestamp.
              ///
              /// `null` for simulated/executed transactions as they are not included in a checkpoint.
              var timestamp: SuiGraphQL.DateTime? { __data["timestamp"] }

              /// SimulateTransaction.Effects.Events.Node.Sender
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
                    DryRunTransactionBlockQuery.Data.SimulateTransaction.Effects.Events.Node.Sender
                      .self
                  ]
                }

                /// The Address' identifier, a 32-byte number represented as a 64-character hex string, with a lead "0x".
                var address: SuiGraphQL.SuiAddress { __data["address"] }
              }

              /// SimulateTransaction.Effects.Events.Node.Contents
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
                    .field("bcs", SuiGraphQL.Base64?.self),
                  ]
                }
                static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
                  [
                    DryRunTransactionBlockQuery.Data.SimulateTransaction.Effects.Events.Node
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
                /// The BCS representation of this value, Base64-encoded.
                var bcs: SuiGraphQL.Base64? { __data["bcs"] }
              }
            }
          }
        }
      }
    }
  }

}
