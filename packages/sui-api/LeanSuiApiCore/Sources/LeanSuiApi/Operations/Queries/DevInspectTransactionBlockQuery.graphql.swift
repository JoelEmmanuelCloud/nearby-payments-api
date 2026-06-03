// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

extension SuiGraphQL {
  nonisolated struct DevInspectTransactionBlockQuery: GraphQLQuery {
    static let operationName: String = "devInspectTransactionBlock"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query devInspectTransactionBlock($transaction: JSON!, $showBalanceChanges: Boolean = false, $showEffects: Boolean = false, $showRawEffects: Boolean = false, $showEvents: Boolean = false, $showObjectChanges: Boolean = false) { simulateTransaction(transaction: $transaction) { __typename outputs { __typename mutatedReferences { __typename argument { __typename ... on Input { inputIndex: ix } ... on TxResult { cmd resultIndex: ix } } value { __typename type { __typename repr } bcs } } returnValues { __typename value { __typename type { __typename repr } bcs } } } effects { __typename effectsBcs @include(if: $showEffects) effectsBcs @include(if: $showRawEffects) balanceChanges @include(if: $showBalanceChanges) { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename owner { __typename address } coinType { __typename repr } amount } } objectChanges @include(if: $showObjectChanges) { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename address inputState { __typename version } outputState { __typename version } } } events @include(if: $showEvents) { __typename nodes { __typename sender { __typename address } } } } } }"#
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
          DevInspectTransactionBlockQuery.Data.self
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
            .field("outputs", [Output]?.self),
            .field("effects", Effects?.self),
          ]
        }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
          [
            DevInspectTransactionBlockQuery.Data.SimulateTransaction.self
          ]
        }

        /// The intermediate outputs for each command of the transaction simulation, including contents of mutated references and return values.
        var outputs: [Output]? { __data["outputs"] }
        /// The predicted effects of the transaction if it were executed.
        var effects: Effects? { __data["effects"] }

        /// SimulateTransaction.Output
        ///
        /// Parent Type: `CommandResult`
        nonisolated struct Output: SuiGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.CommandResult }
          static var __selections: [ApolloAPI.Selection] {
            [
              .field("__typename", String.self),
              .field("mutatedReferences", [MutatedReference]?.self),
              .field("returnValues", [ReturnValue]?.self),
            ]
          }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
            [
              DevInspectTransactionBlockQuery.Data.SimulateTransaction.Output.self
            ]
          }

          /// Changes made to arguments that were mutably borrowed by each command in this transaction.
          var mutatedReferences: [MutatedReference]? { __data["mutatedReferences"] }
          /// Return results of each command in this transaction.
          var returnValues: [ReturnValue]? { __data["returnValues"] }

          /// SimulateTransaction.Output.MutatedReference
          ///
          /// Parent Type: `CommandOutput`
          nonisolated struct MutatedReference: SuiGraphQL.SelectionSet {
            let __data: DataDict
            init(_dataDict: DataDict) { __data = _dataDict }

            static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.CommandOutput }
            static var __selections: [ApolloAPI.Selection] {
              [
                .field("__typename", String.self),
                .field("argument", Argument?.self),
                .field("value", Value?.self),
              ]
            }
            static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
              [
                DevInspectTransactionBlockQuery.Data.SimulateTransaction.Output.MutatedReference
                  .self
              ]
            }

            /// The transaction argument that this value corresponds to (if any).
            var argument: Argument? { __data["argument"] }
            /// The structured Move value, if available.
            var value: Value? { __data["value"] }

            /// SimulateTransaction.Output.MutatedReference.Argument
            ///
            /// Parent Type: `TransactionArgument`
            nonisolated struct Argument: SuiGraphQL.SelectionSet {
              let __data: DataDict
              init(_dataDict: DataDict) { __data = _dataDict }

              static var __parentType: any ApolloAPI.ParentType {
                SuiGraphQL.Unions.TransactionArgument
              }
              static var __selections: [ApolloAPI.Selection] {
                [
                  .field("__typename", String.self),
                  .inlineFragment(AsInput.self),
                  .inlineFragment(AsTxResult.self),
                ]
              }
              static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
                [
                  DevInspectTransactionBlockQuery.Data.SimulateTransaction.Output.MutatedReference
                    .Argument.self
                ]
              }

              var asInput: AsInput? { _asInlineFragment() }
              var asTxResult: AsTxResult? { _asInlineFragment() }

              /// SimulateTransaction.Output.MutatedReference.Argument.AsInput
              ///
              /// Parent Type: `Input`
              nonisolated struct AsInput: SuiGraphQL.InlineFragment {
                let __data: DataDict
                init(_dataDict: DataDict) { __data = _dataDict }

                typealias RootEntityType = DevInspectTransactionBlockQuery.Data.SimulateTransaction
                  .Output.MutatedReference.Argument
                static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Input }
                static var __selections: [ApolloAPI.Selection] {
                  [
                    .field("ix", alias: "inputIndex", Int?.self)
                  ]
                }
                static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
                  [
                    DevInspectTransactionBlockQuery.Data.SimulateTransaction.Output.MutatedReference
                      .Argument.self,
                    DevInspectTransactionBlockQuery.Data.SimulateTransaction.Output.MutatedReference
                      .Argument.AsInput.self,
                  ]
                }

                /// The index of the input.
                var inputIndex: Int? { __data["inputIndex"] }
              }

              /// SimulateTransaction.Output.MutatedReference.Argument.AsTxResult
              ///
              /// Parent Type: `TxResult`
              nonisolated struct AsTxResult: SuiGraphQL.InlineFragment {
                let __data: DataDict
                init(_dataDict: DataDict) { __data = _dataDict }

                typealias RootEntityType = DevInspectTransactionBlockQuery.Data.SimulateTransaction
                  .Output.MutatedReference.Argument
                static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.TxResult }
                static var __selections: [ApolloAPI.Selection] {
                  [
                    .field("cmd", Int?.self),
                    .field("ix", alias: "resultIndex", Int?.self),
                  ]
                }
                static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
                  [
                    DevInspectTransactionBlockQuery.Data.SimulateTransaction.Output.MutatedReference
                      .Argument.self,
                    DevInspectTransactionBlockQuery.Data.SimulateTransaction.Output.MutatedReference
                      .Argument.AsTxResult.self,
                  ]
                }

                /// The index of the command that produced this result.
                var cmd: Int? { __data["cmd"] }
                /// For nested results, the index within the result.
                var resultIndex: Int? { __data["resultIndex"] }
              }
            }

            /// SimulateTransaction.Output.MutatedReference.Value
            ///
            /// Parent Type: `MoveValue`
            nonisolated struct Value: SuiGraphQL.SelectionSet {
              let __data: DataDict
              init(_dataDict: DataDict) { __data = _dataDict }

              static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.MoveValue }
              static var __selections: [ApolloAPI.Selection] {
                [
                  .field("__typename", String.self),
                  .field("type", Type_SelectionSet?.self),
                  .field("bcs", SuiGraphQL.Base64?.self),
                ]
              }
              static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
                [
                  DevInspectTransactionBlockQuery.Data.SimulateTransaction.Output.MutatedReference
                    .Value.self
                ]
              }

              /// The value's type.
              var type: Type_SelectionSet? { __data["type"] }
              /// The BCS representation of this value, Base64-encoded.
              var bcs: SuiGraphQL.Base64? { __data["bcs"] }

              /// SimulateTransaction.Output.MutatedReference.Value.Type_SelectionSet
              ///
              /// Parent Type: `MoveType`
              nonisolated struct Type_SelectionSet: SuiGraphQL.SelectionSet {
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
                    DevInspectTransactionBlockQuery.Data.SimulateTransaction.Output.MutatedReference
                      .Value.Type_SelectionSet.self
                  ]
                }

                /// Flat representation of the type signature, as a displayable string.
                var repr: String { __data["repr"] }
              }
            }
          }

          /// SimulateTransaction.Output.ReturnValue
          ///
          /// Parent Type: `CommandOutput`
          nonisolated struct ReturnValue: SuiGraphQL.SelectionSet {
            let __data: DataDict
            init(_dataDict: DataDict) { __data = _dataDict }

            static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.CommandOutput }
            static var __selections: [ApolloAPI.Selection] {
              [
                .field("__typename", String.self),
                .field("value", Value?.self),
              ]
            }
            static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
              [
                DevInspectTransactionBlockQuery.Data.SimulateTransaction.Output.ReturnValue.self
              ]
            }

            /// The structured Move value, if available.
            var value: Value? { __data["value"] }

            /// SimulateTransaction.Output.ReturnValue.Value
            ///
            /// Parent Type: `MoveValue`
            nonisolated struct Value: SuiGraphQL.SelectionSet {
              let __data: DataDict
              init(_dataDict: DataDict) { __data = _dataDict }

              static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.MoveValue }
              static var __selections: [ApolloAPI.Selection] {
                [
                  .field("__typename", String.self),
                  .field("type", Type_SelectionSet?.self),
                  .field("bcs", SuiGraphQL.Base64?.self),
                ]
              }
              static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
                [
                  DevInspectTransactionBlockQuery.Data.SimulateTransaction.Output.ReturnValue.Value
                    .self
                ]
              }

              /// The value's type.
              var type: Type_SelectionSet? { __data["type"] }
              /// The BCS representation of this value, Base64-encoded.
              var bcs: SuiGraphQL.Base64? { __data["bcs"] }

              /// SimulateTransaction.Output.ReturnValue.Value.Type_SelectionSet
              ///
              /// Parent Type: `MoveType`
              nonisolated struct Type_SelectionSet: SuiGraphQL.SelectionSet {
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
                    DevInspectTransactionBlockQuery.Data.SimulateTransaction.Output.ReturnValue
                      .Value.Type_SelectionSet.self
                  ]
                }

                /// Flat representation of the type signature, as a displayable string.
                var repr: String { __data["repr"] }
              }
            }
          }
        }

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
              DevInspectTransactionBlockQuery.Data.SimulateTransaction.Effects.self
            ]
          }

          /// The Base64-encoded BCS serialization of these effects, as `TransactionEffects`.
          var effectsBcs: SuiGraphQL.Base64? { __data["effectsBcs"] }
          /// The effect this transaction had on the balances (sum of coin values per coin type) of addresses and objects.
          var balanceChanges: BalanceChanges? { __data["balanceChanges"] }
          /// The before and after state of objects that were modified by this transaction.
          var objectChanges: ObjectChanges? { __data["objectChanges"] }
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
                DevInspectTransactionBlockQuery.Data.SimulateTransaction.Effects.BalanceChanges.self
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
                  DevInspectTransactionBlockQuery.Data.SimulateTransaction.Effects.BalanceChanges
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
                  DevInspectTransactionBlockQuery.Data.SimulateTransaction.Effects.BalanceChanges
                    .Node.self
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
                    DevInspectTransactionBlockQuery.Data.SimulateTransaction.Effects.BalanceChanges
                      .Node.Owner.self
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
                    DevInspectTransactionBlockQuery.Data.SimulateTransaction.Effects.BalanceChanges
                      .Node.CoinType.self
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
                DevInspectTransactionBlockQuery.Data.SimulateTransaction.Effects.ObjectChanges.self
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
                  DevInspectTransactionBlockQuery.Data.SimulateTransaction.Effects.ObjectChanges
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
                  DevInspectTransactionBlockQuery.Data.SimulateTransaction.Effects.ObjectChanges
                    .Node.self
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
                    DevInspectTransactionBlockQuery.Data.SimulateTransaction.Effects.ObjectChanges
                      .Node.InputState.self
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
                    DevInspectTransactionBlockQuery.Data.SimulateTransaction.Effects.ObjectChanges
                      .Node.OutputState.self
                  ]
                }

                /// The version of this object that this content comes from.
                var version: SuiGraphQL.UInt53? { __data["version"] }
              }
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
                DevInspectTransactionBlockQuery.Data.SimulateTransaction.Effects.Events.self
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
                ]
              }
              static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
                [
                  DevInspectTransactionBlockQuery.Data.SimulateTransaction.Effects.Events.Node.self
                ]
              }

              /// Address of the sender of the transaction that emitted this event.
              var sender: Sender? { __data["sender"] }

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
                    DevInspectTransactionBlockQuery.Data.SimulateTransaction.Effects.Events.Node
                      .Sender.self
                  ]
                }

                /// The Address' identifier, a 32-byte number represented as a 64-character hex string, with a lead "0x".
                var address: SuiGraphQL.SuiAddress { __data["address"] }
              }
            }
          }
        }
      }
    }
  }

}
