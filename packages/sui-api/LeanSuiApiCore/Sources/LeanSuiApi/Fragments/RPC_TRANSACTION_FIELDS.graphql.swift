// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

extension SuiGraphQL {
  nonisolated struct RPC_TRANSACTION_FIELDS: SuiGraphQL.SelectionSet, Fragment {
    static var fragmentDefinition: StaticString {
      #"fragment RPC_TRANSACTION_FIELDS on Transaction { __typename digest rawTransaction: transactionBcs @include(if: $showInput) rawTransaction: transactionBcs @include(if: $showRawInput) sender { __typename address } signatures { __typename signatureBytes } effects { __typename status executionError { __typename message } bcs: effectsBcs @include(if: $showEffects) bcs: effectsBcs @include(if: $showObjectChanges) bcs: effectsBcs @include(if: $showRawEffects) events @include(if: $showEvents) { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename ...RPC_EVENTS_FIELDS } } checkpoint { __typename sequenceNumber } timestamp balanceChanges @include(if: $showBalanceChanges) { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename coinType { __typename repr } owner { __typename address } amount } } objectChanges @include(if: $showObjectChanges) { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename address inputState { __typename version asMoveObject { __typename contents { __typename type { __typename repr } } } } outputState { __typename asMoveObject { __typename contents { __typename type { __typename repr } } } asMovePackage { __typename modules(first: 10) { __typename nodes { __typename name } } } } } } } }"#
    }

    let __data: DataDict
    init(_dataDict: DataDict) { __data = _dataDict }

    static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Transaction }
    static var __selections: [ApolloAPI.Selection] {
      [
        .field("__typename", String.self),
        .field("digest", String.self),
        .field("sender", Sender?.self),
        .field("signatures", [Signature].self),
        .field("effects", Effects?.self),
        .include(
          if: "showInput" || "showRawInput",
          .field("transactionBcs", alias: "rawTransaction", SuiGraphQL.Base64?.self)),
      ]
    }
    static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
      [
        RPC_TRANSACTION_FIELDS.self
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

    /// Sender
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
          RPC_TRANSACTION_FIELDS.Sender.self
        ]
      }

      /// The Address' identifier, a 32-byte number represented as a 64-character hex string, with a lead "0x".
      var address: SuiGraphQL.SuiAddress { __data["address"] }
    }

    /// Signature
    ///
    /// Parent Type: `UserSignature`
    nonisolated struct Signature: SuiGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.UserSignature }
      static var __selections: [ApolloAPI.Selection] {
        [
          .field("__typename", String.self),
          .field("signatureBytes", SuiGraphQL.Base64?.self),
        ]
      }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
        [
          RPC_TRANSACTION_FIELDS.Signature.self
        ]
      }

      /// The signature bytes, Base64-encoded.
      /// For simple signatures: flag || signature || pubkey
      /// For complex signatures: flag || bcs_serialized_struct
      var signatureBytes: SuiGraphQL.Base64? { __data["signatureBytes"] }
    }

    /// Effects
    ///
    /// Parent Type: `TransactionEffects`
    nonisolated struct Effects: SuiGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.TransactionEffects }
      static var __selections: [ApolloAPI.Selection] {
        [
          .field("__typename", String.self),
          .field("status", GraphQLEnum<SuiGraphQL.ExecutionStatus>?.self),
          .field("executionError", ExecutionError?.self),
          .field("checkpoint", Checkpoint?.self),
          .field("timestamp", SuiGraphQL.DateTime?.self),
          .include(
            if: "showEffects" || "showObjectChanges" || "showRawEffects",
            .field("effectsBcs", alias: "bcs", SuiGraphQL.Base64?.self)),
          .include(if: "showEvents", .field("events", Events?.self)),
          .include(if: "showBalanceChanges", .field("balanceChanges", BalanceChanges?.self)),
          .include(if: "showObjectChanges", .field("objectChanges", ObjectChanges?.self)),
        ]
      }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
        [
          RPC_TRANSACTION_FIELDS.Effects.self
        ]
      }

      /// Whether the transaction executed successfully or not.
      var status: GraphQLEnum<SuiGraphQL.ExecutionStatus>? { __data["status"] }
      /// Rich execution error information for failed transactions.
      var executionError: ExecutionError? { __data["executionError"] }
      /// The Base64-encoded BCS serialization of these effects, as `TransactionEffects`.
      var bcs: SuiGraphQL.Base64? { __data["bcs"] }
      /// Events emitted by this transaction.
      var events: Events? { __data["events"] }
      /// The checkpoint this transaction was finalized in.
      var checkpoint: Checkpoint? { __data["checkpoint"] }
      /// Timestamp corresponding to the checkpoint this transaction was finalized in.
      ///
      /// `null` for executed/simulated transactions that have not been included in a checkpoint.
      var timestamp: SuiGraphQL.DateTime? { __data["timestamp"] }
      /// The effect this transaction had on the balances (sum of coin values per coin type) of addresses and objects.
      var balanceChanges: BalanceChanges? { __data["balanceChanges"] }
      /// The before and after state of objects that were modified by this transaction.
      var objectChanges: ObjectChanges? { __data["objectChanges"] }

      /// Effects.ExecutionError
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
            RPC_TRANSACTION_FIELDS.Effects.ExecutionError.self
          ]
        }

        /// Human readable explanation of why the transaction failed.
        ///
        /// For Move aborts, the error message will be resolved to a human-readable form if possible, otherwise it will fall back to displaying the abort code and location.
        var message: String { __data["message"] }
      }

      /// Effects.Events
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
            RPC_TRANSACTION_FIELDS.Effects.Events.self
          ]
        }

        /// Information to aid in pagination.
        var pageInfo: PageInfo { __data["pageInfo"] }
        /// A list of nodes.
        var nodes: [Node] { __data["nodes"] }

        /// Effects.Events.PageInfo
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
              RPC_TRANSACTION_FIELDS.Effects.Events.PageInfo.self
            ]
          }

          /// When paginating forwards, are there more items?
          var hasNextPage: Bool { __data["hasNextPage"] }
          /// When paginating forwards, the cursor to continue.
          var endCursor: String? { __data["endCursor"] }
        }

        /// Effects.Events.Node
        ///
        /// Parent Type: `Event`
        nonisolated struct Node: SuiGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Event }
          static var __selections: [ApolloAPI.Selection] {
            [
              .field("__typename", String.self),
              .fragment(RPC_EVENTS_FIELDS.self),
            ]
          }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
            [
              RPC_TRANSACTION_FIELDS.Effects.Events.Node.self,
              RPC_EVENTS_FIELDS.self,
            ]
          }

          /// The module containing the function that was called in the programmable transaction, that resulted in this event being emitted.
          var transactionModule: TransactionModule? { __data["transactionModule"] }
          /// Address of the sender of the transaction that emitted this event.
          var sender: Sender? { __data["sender"] }
          /// The Move value emitted for this event.
          var contents: Contents? { __data["contents"] }
          /// Timestamp corresponding to the checkpoint this event's transaction was finalized in.
          /// All events from the same transaction share the same timestamp.
          ///
          /// `null` for simulated/executed transactions as they are not included in a checkpoint.
          var timestamp: SuiGraphQL.DateTime? { __data["timestamp"] }

          struct Fragments: FragmentContainer {
            let __data: DataDict
            init(_dataDict: DataDict) { __data = _dataDict }

            var rPC_EVENTS_FIELDS: RPC_EVENTS_FIELDS { _toFragment() }
          }

          typealias TransactionModule = RPC_EVENTS_FIELDS.TransactionModule

          typealias Sender = RPC_EVENTS_FIELDS.Sender

          typealias Contents = RPC_EVENTS_FIELDS.Contents
        }
      }

      /// Effects.Checkpoint
      ///
      /// Parent Type: `Checkpoint`
      nonisolated struct Checkpoint: SuiGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Checkpoint }
        static var __selections: [ApolloAPI.Selection] {
          [
            .field("__typename", String.self),
            .field("sequenceNumber", SuiGraphQL.UInt53.self),
          ]
        }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
          [
            RPC_TRANSACTION_FIELDS.Effects.Checkpoint.self
          ]
        }

        /// The checkpoint's position in the total order of finalized checkpoints, agreed upon by consensus.
        var sequenceNumber: SuiGraphQL.UInt53 { __data["sequenceNumber"] }
      }

      /// Effects.BalanceChanges
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
            RPC_TRANSACTION_FIELDS.Effects.BalanceChanges.self
          ]
        }

        /// Information to aid in pagination.
        var pageInfo: PageInfo { __data["pageInfo"] }
        /// A list of nodes.
        var nodes: [Node] { __data["nodes"] }

        /// Effects.BalanceChanges.PageInfo
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
              RPC_TRANSACTION_FIELDS.Effects.BalanceChanges.PageInfo.self
            ]
          }

          /// When paginating forwards, are there more items?
          var hasNextPage: Bool { __data["hasNextPage"] }
          /// When paginating forwards, the cursor to continue.
          var endCursor: String? { __data["endCursor"] }
        }

        /// Effects.BalanceChanges.Node
        ///
        /// Parent Type: `BalanceChange`
        nonisolated struct Node: SuiGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.BalanceChange }
          static var __selections: [ApolloAPI.Selection] {
            [
              .field("__typename", String.self),
              .field("coinType", CoinType?.self),
              .field("owner", Owner?.self),
              .field("amount", SuiGraphQL.BigInt?.self),
            ]
          }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
            [
              RPC_TRANSACTION_FIELDS.Effects.BalanceChanges.Node.self
            ]
          }

          /// The inner type of the coin whose balance has changed (e.g. `0x2::sui::SUI`).
          var coinType: CoinType? { __data["coinType"] }
          /// The address or object whose balance has changed.
          var owner: Owner? { __data["owner"] }
          /// The signed balance change.
          var amount: SuiGraphQL.BigInt? { __data["amount"] }

          /// Effects.BalanceChanges.Node.CoinType
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
                RPC_TRANSACTION_FIELDS.Effects.BalanceChanges.Node.CoinType.self
              ]
            }

            /// Flat representation of the type signature, as a displayable string.
            var repr: String { __data["repr"] }
          }

          /// Effects.BalanceChanges.Node.Owner
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
                RPC_TRANSACTION_FIELDS.Effects.BalanceChanges.Node.Owner.self
              ]
            }

            /// The Address' identifier, a 32-byte number represented as a 64-character hex string, with a lead "0x".
            var address: SuiGraphQL.SuiAddress { __data["address"] }
          }
        }
      }

      /// Effects.ObjectChanges
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
            RPC_TRANSACTION_FIELDS.Effects.ObjectChanges.self
          ]
        }

        /// Information to aid in pagination.
        var pageInfo: PageInfo { __data["pageInfo"] }
        /// A list of nodes.
        var nodes: [Node] { __data["nodes"] }

        /// Effects.ObjectChanges.PageInfo
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
              RPC_TRANSACTION_FIELDS.Effects.ObjectChanges.PageInfo.self
            ]
          }

          /// When paginating forwards, are there more items?
          var hasNextPage: Bool { __data["hasNextPage"] }
          /// When paginating forwards, the cursor to continue.
          var endCursor: String? { __data["endCursor"] }
        }

        /// Effects.ObjectChanges.Node
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
              RPC_TRANSACTION_FIELDS.Effects.ObjectChanges.Node.self
            ]
          }

          /// The address of the object that has changed.
          var address: SuiGraphQL.SuiAddress { __data["address"] }
          /// The contents of the object immediately before the transaction.
          var inputState: InputState? { __data["inputState"] }
          /// The contents of the object immediately after the transaction.
          var outputState: OutputState? { __data["outputState"] }

          /// Effects.ObjectChanges.Node.InputState
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
                .field("asMoveObject", AsMoveObject?.self),
              ]
            }
            static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
              [
                RPC_TRANSACTION_FIELDS.Effects.ObjectChanges.Node.InputState.self
              ]
            }

            /// The version of this object that this content comes from.
            var version: SuiGraphQL.UInt53? { __data["version"] }
            /// Attempts to convert the object into a MoveObject.
            var asMoveObject: AsMoveObject? { __data["asMoveObject"] }

            /// Effects.ObjectChanges.Node.InputState.AsMoveObject
            ///
            /// Parent Type: `MoveObject`
            nonisolated struct AsMoveObject: SuiGraphQL.SelectionSet {
              let __data: DataDict
              init(_dataDict: DataDict) { __data = _dataDict }

              static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.MoveObject }
              static var __selections: [ApolloAPI.Selection] {
                [
                  .field("__typename", String.self),
                  .field("contents", Contents?.self),
                ]
              }
              static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
                [
                  RPC_TRANSACTION_FIELDS.Effects.ObjectChanges.Node.InputState.AsMoveObject.self
                ]
              }

              /// The structured representation of the object's contents.
              var contents: Contents? { __data["contents"] }

              /// Effects.ObjectChanges.Node.InputState.AsMoveObject.Contents
              ///
              /// Parent Type: `MoveValue`
              nonisolated struct Contents: SuiGraphQL.SelectionSet {
                let __data: DataDict
                init(_dataDict: DataDict) { __data = _dataDict }

                static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.MoveValue }
                static var __selections: [ApolloAPI.Selection] {
                  [
                    .field("__typename", String.self),
                    .field("type", Type_SelectionSet?.self),
                  ]
                }
                static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
                  [
                    RPC_TRANSACTION_FIELDS.Effects.ObjectChanges.Node.InputState.AsMoveObject
                      .Contents.self
                  ]
                }

                /// The value's type.
                var type: Type_SelectionSet? { __data["type"] }

                /// Effects.ObjectChanges.Node.InputState.AsMoveObject.Contents.Type_SelectionSet
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
                      RPC_TRANSACTION_FIELDS.Effects.ObjectChanges.Node.InputState.AsMoveObject
                        .Contents.Type_SelectionSet.self
                    ]
                  }

                  /// Flat representation of the type signature, as a displayable string.
                  var repr: String { __data["repr"] }
                }
              }
            }
          }

          /// Effects.ObjectChanges.Node.OutputState
          ///
          /// Parent Type: `Object`
          nonisolated struct OutputState: SuiGraphQL.SelectionSet {
            let __data: DataDict
            init(_dataDict: DataDict) { __data = _dataDict }

            static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Object }
            static var __selections: [ApolloAPI.Selection] {
              [
                .field("__typename", String.self),
                .field("asMoveObject", AsMoveObject?.self),
                .field("asMovePackage", AsMovePackage?.self),
              ]
            }
            static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
              [
                RPC_TRANSACTION_FIELDS.Effects.ObjectChanges.Node.OutputState.self
              ]
            }

            /// Attempts to convert the object into a MoveObject.
            var asMoveObject: AsMoveObject? { __data["asMoveObject"] }
            /// Attempts to convert the object into a MovePackage.
            var asMovePackage: AsMovePackage? { __data["asMovePackage"] }

            /// Effects.ObjectChanges.Node.OutputState.AsMoveObject
            ///
            /// Parent Type: `MoveObject`
            nonisolated struct AsMoveObject: SuiGraphQL.SelectionSet {
              let __data: DataDict
              init(_dataDict: DataDict) { __data = _dataDict }

              static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.MoveObject }
              static var __selections: [ApolloAPI.Selection] {
                [
                  .field("__typename", String.self),
                  .field("contents", Contents?.self),
                ]
              }
              static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
                [
                  RPC_TRANSACTION_FIELDS.Effects.ObjectChanges.Node.OutputState.AsMoveObject.self
                ]
              }

              /// The structured representation of the object's contents.
              var contents: Contents? { __data["contents"] }

              /// Effects.ObjectChanges.Node.OutputState.AsMoveObject.Contents
              ///
              /// Parent Type: `MoveValue`
              nonisolated struct Contents: SuiGraphQL.SelectionSet {
                let __data: DataDict
                init(_dataDict: DataDict) { __data = _dataDict }

                static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.MoveValue }
                static var __selections: [ApolloAPI.Selection] {
                  [
                    .field("__typename", String.self),
                    .field("type", Type_SelectionSet?.self),
                  ]
                }
                static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
                  [
                    RPC_TRANSACTION_FIELDS.Effects.ObjectChanges.Node.OutputState.AsMoveObject
                      .Contents.self
                  ]
                }

                /// The value's type.
                var type: Type_SelectionSet? { __data["type"] }

                /// Effects.ObjectChanges.Node.OutputState.AsMoveObject.Contents.Type_SelectionSet
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
                      RPC_TRANSACTION_FIELDS.Effects.ObjectChanges.Node.OutputState.AsMoveObject
                        .Contents.Type_SelectionSet.self
                    ]
                  }

                  /// Flat representation of the type signature, as a displayable string.
                  var repr: String { __data["repr"] }
                }
              }
            }

            /// Effects.ObjectChanges.Node.OutputState.AsMovePackage
            ///
            /// Parent Type: `MovePackage`
            nonisolated struct AsMovePackage: SuiGraphQL.SelectionSet {
              let __data: DataDict
              init(_dataDict: DataDict) { __data = _dataDict }

              static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.MovePackage }
              static var __selections: [ApolloAPI.Selection] {
                [
                  .field("__typename", String.self),
                  .field("modules", Modules?.self, arguments: ["first": 10]),
                ]
              }
              static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
                [
                  RPC_TRANSACTION_FIELDS.Effects.ObjectChanges.Node.OutputState.AsMovePackage.self
                ]
              }

              /// Paginate through this package's modules.
              var modules: Modules? { __data["modules"] }

              /// Effects.ObjectChanges.Node.OutputState.AsMovePackage.Modules
              ///
              /// Parent Type: `MoveModuleConnection`
              nonisolated struct Modules: SuiGraphQL.SelectionSet {
                let __data: DataDict
                init(_dataDict: DataDict) { __data = _dataDict }

                static var __parentType: any ApolloAPI.ParentType {
                  SuiGraphQL.Objects.MoveModuleConnection
                }
                static var __selections: [ApolloAPI.Selection] {
                  [
                    .field("__typename", String.self),
                    .field("nodes", [Node].self),
                  ]
                }
                static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
                  [
                    RPC_TRANSACTION_FIELDS.Effects.ObjectChanges.Node.OutputState.AsMovePackage
                      .Modules.self
                  ]
                }

                /// A list of nodes.
                var nodes: [Node] { __data["nodes"] }

                /// Effects.ObjectChanges.Node.OutputState.AsMovePackage.Modules.Node
                ///
                /// Parent Type: `MoveModule`
                nonisolated struct Node: SuiGraphQL.SelectionSet {
                  let __data: DataDict
                  init(_dataDict: DataDict) { __data = _dataDict }

                  static var __parentType: any ApolloAPI.ParentType {
                    SuiGraphQL.Objects.MoveModule
                  }
                  static var __selections: [ApolloAPI.Selection] {
                    [
                      .field("__typename", String.self),
                      .field("name", String.self),
                    ]
                  }
                  static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
                    [
                      RPC_TRANSACTION_FIELDS.Effects.ObjectChanges.Node.OutputState.AsMovePackage
                        .Modules.Node.self
                    ]
                  }

                  /// The module's unqualified name.
                  var name: String { __data["name"] }
                }
              }
            }
          }
        }
      }
    }
  }

}
