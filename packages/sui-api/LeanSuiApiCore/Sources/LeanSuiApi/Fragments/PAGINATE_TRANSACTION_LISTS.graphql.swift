// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

extension SuiGraphQL {
  nonisolated struct PAGINATE_TRANSACTION_LISTS: SuiGraphQL.SelectionSet, Fragment {
    static var fragmentDefinition: StaticString {
      #"fragment PAGINATE_TRANSACTION_LISTS on Transaction { __typename effects { __typename events(after: $afterEvents) @include(if: $hasMoreEvents) { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename ...RPC_EVENTS_FIELDS } } balanceChanges(after: $afterBalanceChanges) @include(if: $hasMoreBalanceChanges) { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename coinType { __typename repr } owner { __typename address } amount } } objectChanges(after: $afterObjectChanges) @include(if: $hasMoreObjectChanges) { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename address inputState { __typename version asMoveObject { __typename contents { __typename type { __typename repr } } } } outputState { __typename asMoveObject { __typename contents { __typename type { __typename repr } } } asMovePackage { __typename modules(first: 10) { __typename nodes { __typename name } } } } } } } }"#
    }

    let __data: DataDict
    init(_dataDict: DataDict) { __data = _dataDict }

    static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Transaction }
    static var __selections: [ApolloAPI.Selection] {
      [
        .field("__typename", String.self),
        .field("effects", Effects?.self),
      ]
    }
    static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
      [
        PAGINATE_TRANSACTION_LISTS.self
      ]
    }

    /// The results to the chain of executing this transaction.
    var effects: Effects? { __data["effects"] }

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
          .include(
            if: "hasMoreEvents",
            .field("events", Events?.self, arguments: ["after": .variable("afterEvents")])),
          .include(
            if: "hasMoreBalanceChanges",
            .field(
              "balanceChanges", BalanceChanges?.self,
              arguments: ["after": .variable("afterBalanceChanges")])),
          .include(
            if: "hasMoreObjectChanges",
            .field(
              "objectChanges", ObjectChanges?.self,
              arguments: ["after": .variable("afterObjectChanges")])),
        ]
      }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
        [
          PAGINATE_TRANSACTION_LISTS.Effects.self
        ]
      }

      /// Events emitted by this transaction.
      var events: Events? { __data["events"] }
      /// The effect this transaction had on the balances (sum of coin values per coin type) of addresses and objects.
      var balanceChanges: BalanceChanges? { __data["balanceChanges"] }
      /// The before and after state of objects that were modified by this transaction.
      var objectChanges: ObjectChanges? { __data["objectChanges"] }

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
            PAGINATE_TRANSACTION_LISTS.Effects.Events.self
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
              PAGINATE_TRANSACTION_LISTS.Effects.Events.PageInfo.self
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
              PAGINATE_TRANSACTION_LISTS.Effects.Events.Node.self,
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
            PAGINATE_TRANSACTION_LISTS.Effects.BalanceChanges.self
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
              PAGINATE_TRANSACTION_LISTS.Effects.BalanceChanges.PageInfo.self
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
              PAGINATE_TRANSACTION_LISTS.Effects.BalanceChanges.Node.self
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
                PAGINATE_TRANSACTION_LISTS.Effects.BalanceChanges.Node.CoinType.self
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
                PAGINATE_TRANSACTION_LISTS.Effects.BalanceChanges.Node.Owner.self
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
            PAGINATE_TRANSACTION_LISTS.Effects.ObjectChanges.self
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
              PAGINATE_TRANSACTION_LISTS.Effects.ObjectChanges.PageInfo.self
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
              PAGINATE_TRANSACTION_LISTS.Effects.ObjectChanges.Node.self
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
                PAGINATE_TRANSACTION_LISTS.Effects.ObjectChanges.Node.InputState.self
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
                  PAGINATE_TRANSACTION_LISTS.Effects.ObjectChanges.Node.InputState.AsMoveObject.self
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
                    PAGINATE_TRANSACTION_LISTS.Effects.ObjectChanges.Node.InputState.AsMoveObject
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
                      PAGINATE_TRANSACTION_LISTS.Effects.ObjectChanges.Node.InputState.AsMoveObject
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
                PAGINATE_TRANSACTION_LISTS.Effects.ObjectChanges.Node.OutputState.self
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
                  PAGINATE_TRANSACTION_LISTS.Effects.ObjectChanges.Node.OutputState.AsMoveObject
                    .self
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
                    PAGINATE_TRANSACTION_LISTS.Effects.ObjectChanges.Node.OutputState.AsMoveObject
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
                      PAGINATE_TRANSACTION_LISTS.Effects.ObjectChanges.Node.OutputState.AsMoveObject
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
                  PAGINATE_TRANSACTION_LISTS.Effects.ObjectChanges.Node.OutputState.AsMovePackage
                    .self
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
                    PAGINATE_TRANSACTION_LISTS.Effects.ObjectChanges.Node.OutputState.AsMovePackage
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
                      PAGINATE_TRANSACTION_LISTS.Effects.ObjectChanges.Node.OutputState
                        .AsMovePackage.Modules.Node.self
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
