// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

extension SuiGraphQL {
  nonisolated struct ACCOUNT_ACTIVITY_FIELDS: SuiGraphQL.SelectionSet, Fragment {
    static var fragmentDefinition: StaticString {
      #"fragment ACCOUNT_ACTIVITY_FIELDS on Transaction { __typename digest sender { __typename address } effects { __typename status executionError { __typename message } timestamp balanceChanges { __typename nodes { __typename coinType { __typename repr } owner { __typename address } amount } } } }"#
    }

    let __data: DataDict
    init(_dataDict: DataDict) { __data = _dataDict }

    static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Transaction }
    static var __selections: [ApolloAPI.Selection] {
      [
        .field("__typename", String.self),
        .field("digest", String.self),
        .field("sender", Sender?.self),
        .field("effects", Effects?.self),
      ]
    }
    static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
      [
        ACCOUNT_ACTIVITY_FIELDS.self
      ]
    }

    /// A 32-byte hash that uniquely identifies the transaction contents, encoded in Base58.
    var digest: String { __data["digest"] }
    /// The address corresponding to the public key that signed this transaction. System transactions do not have senders.
    var sender: Sender? { __data["sender"] }
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
          ACCOUNT_ACTIVITY_FIELDS.Sender.self
        ]
      }

      /// The Address' identifier, a 32-byte number represented as a 64-character hex string, with a lead "0x".
      var address: SuiGraphQL.SuiAddress { __data["address"] }
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
          .field("timestamp", SuiGraphQL.DateTime?.self),
          .field("balanceChanges", BalanceChanges?.self),
        ]
      }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
        [
          ACCOUNT_ACTIVITY_FIELDS.Effects.self
        ]
      }

      /// Whether the transaction executed successfully or not.
      var status: GraphQLEnum<SuiGraphQL.ExecutionStatus>? { __data["status"] }
      /// Rich execution error information for failed transactions.
      var executionError: ExecutionError? { __data["executionError"] }
      /// Timestamp corresponding to the checkpoint this transaction was finalized in.
      ///
      /// `null` for executed/simulated transactions that have not been included in a checkpoint.
      var timestamp: SuiGraphQL.DateTime? { __data["timestamp"] }
      /// The effect this transaction had on the balances (sum of coin values per coin type) of addresses and objects.
      var balanceChanges: BalanceChanges? { __data["balanceChanges"] }

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
            ACCOUNT_ACTIVITY_FIELDS.Effects.ExecutionError.self
          ]
        }

        /// Human readable explanation of why the transaction failed.
        ///
        /// For Move aborts, the error message will be resolved to a human-readable form if possible, otherwise it will fall back to displaying the abort code and location.
        var message: String { __data["message"] }
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
            .field("nodes", [Node].self),
          ]
        }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
          [
            ACCOUNT_ACTIVITY_FIELDS.Effects.BalanceChanges.self
          ]
        }

        /// A list of nodes.
        var nodes: [Node] { __data["nodes"] }

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
              ACCOUNT_ACTIVITY_FIELDS.Effects.BalanceChanges.Node.self
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
                ACCOUNT_ACTIVITY_FIELDS.Effects.BalanceChanges.Node.CoinType.self
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
                ACCOUNT_ACTIVITY_FIELDS.Effects.BalanceChanges.Node.Owner.self
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
