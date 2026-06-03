// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

extension SuiGraphQL {
  nonisolated struct GetCurrentEpochQuery: GraphQLQuery {
    static let operationName: String = "getCurrentEpoch"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query getCurrentEpoch { epoch { __typename epochId totalTransactions firstCheckpoint: checkpoints(first: 1) { __typename nodes { __typename sequenceNumber } } startTimestamp endTimestamp referenceGasPrice validatorSet { __typename contents { __typename json } } } }"#
      ))

    public init() {}

    nonisolated struct Data: SuiGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Query }
      static var __selections: [ApolloAPI.Selection] {
        [
          .field("epoch", Epoch?.self)
        ]
      }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
        [
          GetCurrentEpochQuery.Data.self
        ]
      }

      /// Fetch an epoch by its ID, or fetch the latest epoch if no ID is provided.
      ///
      /// Returns `null` if the epoch does not exist yet, or was pruned.
      var epoch: Epoch? { __data["epoch"] }

      /// Epoch
      ///
      /// Parent Type: `Epoch`
      nonisolated struct Epoch: SuiGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Epoch }
        static var __selections: [ApolloAPI.Selection] {
          [
            .field("__typename", String.self),
            .field("epochId", SuiGraphQL.UInt53.self),
            .field("totalTransactions", SuiGraphQL.UInt53?.self),
            .field(
              "checkpoints", alias: "firstCheckpoint", FirstCheckpoint?.self,
              arguments: ["first": 1]),
            .field("startTimestamp", SuiGraphQL.DateTime?.self),
            .field("endTimestamp", SuiGraphQL.DateTime?.self),
            .field("referenceGasPrice", SuiGraphQL.BigInt?.self),
            .field("validatorSet", ValidatorSet?.self),
          ]
        }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
          [
            GetCurrentEpochQuery.Data.Epoch.self
          ]
        }

        /// The epoch's id as a sequence number that starts at 0 and is incremented by one at every epoch change.
        var epochId: SuiGraphQL.UInt53 { __data["epochId"] }
        /// The total number of transaction blocks in this epoch.
        ///
        /// If the epoch has not finished yet, this number is computed based on the number of transactions at the latest known checkpoint.
        var totalTransactions: SuiGraphQL.UInt53? { __data["totalTransactions"] }
        /// The epoch's corresponding checkpoints.
        var firstCheckpoint: FirstCheckpoint? { __data["firstCheckpoint"] }
        /// The timestamp associated with the first checkpoint in the epoch.
        var startTimestamp: SuiGraphQL.DateTime? { __data["startTimestamp"] }
        /// The timestamp associated with the last checkpoint in the epoch (or `null` if the epoch has not finished yet).
        var endTimestamp: SuiGraphQL.DateTime? { __data["endTimestamp"] }
        /// The minimum gas price that a quorum of validators are guaranteed to sign a transaction for in this epoch.
        var referenceGasPrice: SuiGraphQL.BigInt? { __data["referenceGasPrice"] }
        /// Validator-related properties, including the active validators.
        var validatorSet: ValidatorSet? { __data["validatorSet"] }

        /// Epoch.FirstCheckpoint
        ///
        /// Parent Type: `CheckpointConnection`
        nonisolated struct FirstCheckpoint: SuiGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType {
            SuiGraphQL.Objects.CheckpointConnection
          }
          static var __selections: [ApolloAPI.Selection] {
            [
              .field("__typename", String.self),
              .field("nodes", [Node].self),
            ]
          }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
            [
              GetCurrentEpochQuery.Data.Epoch.FirstCheckpoint.self
            ]
          }

          /// A list of nodes.
          var nodes: [Node] { __data["nodes"] }

          /// Epoch.FirstCheckpoint.Node
          ///
          /// Parent Type: `Checkpoint`
          nonisolated struct Node: SuiGraphQL.SelectionSet {
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
                GetCurrentEpochQuery.Data.Epoch.FirstCheckpoint.Node.self
              ]
            }

            /// The checkpoint's position in the total order of finalized checkpoints, agreed upon by consensus.
            var sequenceNumber: SuiGraphQL.UInt53 { __data["sequenceNumber"] }
          }
        }

        /// Epoch.ValidatorSet
        ///
        /// Parent Type: `ValidatorSet`
        nonisolated struct ValidatorSet: SuiGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.ValidatorSet }
          static var __selections: [ApolloAPI.Selection] {
            [
              .field("__typename", String.self),
              .field("contents", Contents?.self),
            ]
          }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
            [
              GetCurrentEpochQuery.Data.Epoch.ValidatorSet.self
            ]
          }

          /// On-chain representation of the underlying `0x3::validator_set::ValidatorSet` value.
          var contents: Contents? { __data["contents"] }

          /// Epoch.ValidatorSet.Contents
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
                GetCurrentEpochQuery.Data.Epoch.ValidatorSet.Contents.self
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
    }
  }

}
