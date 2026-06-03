// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

extension SuiGraphQL {
  nonisolated struct GetLatestSuiSystemStateQuery: GraphQLQuery {
    static let operationName: String = "getLatestSuiSystemState"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query getLatestSuiSystemState { epoch { __typename epochId startTimestamp endTimestamp referenceGasPrice totalGasFees totalStakeRewards totalStakeSubsidies totalTransactions fundSize protocolConfigs { __typename protocolVersion } systemState { __typename json } validatorSet { __typename contents { __typename json } } } }"#
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
          GetLatestSuiSystemStateQuery.Data.self
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
            .field("startTimestamp", SuiGraphQL.DateTime?.self),
            .field("endTimestamp", SuiGraphQL.DateTime?.self),
            .field("referenceGasPrice", SuiGraphQL.BigInt?.self),
            .field("totalGasFees", SuiGraphQL.BigInt?.self),
            .field("totalStakeRewards", SuiGraphQL.BigInt?.self),
            .field("totalStakeSubsidies", SuiGraphQL.BigInt?.self),
            .field("totalTransactions", SuiGraphQL.UInt53?.self),
            .field("fundSize", SuiGraphQL.BigInt?.self),
            .field("protocolConfigs", ProtocolConfigs?.self),
            .field("systemState", SystemState?.self),
            .field("validatorSet", ValidatorSet?.self),
          ]
        }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
          [
            GetLatestSuiSystemStateQuery.Data.Epoch.self
          ]
        }

        /// The epoch's id as a sequence number that starts at 0 and is incremented by one at every epoch change.
        var epochId: SuiGraphQL.UInt53 { __data["epochId"] }
        /// The timestamp associated with the first checkpoint in the epoch.
        var startTimestamp: SuiGraphQL.DateTime? { __data["startTimestamp"] }
        /// The timestamp associated with the last checkpoint in the epoch (or `null` if the epoch has not finished yet).
        var endTimestamp: SuiGraphQL.DateTime? { __data["endTimestamp"] }
        /// The minimum gas price that a quorum of validators are guaranteed to sign a transaction for in this epoch.
        var referenceGasPrice: SuiGraphQL.BigInt? { __data["referenceGasPrice"] }
        /// The total amount of gas fees (in MIST) that were paid in this epoch (or `null` if the epoch has not finished yet).
        var totalGasFees: SuiGraphQL.BigInt? { __data["totalGasFees"] }
        /// The total MIST rewarded as stake (or `null` if the epoch has not finished yet).
        var totalStakeRewards: SuiGraphQL.BigInt? { __data["totalStakeRewards"] }
        /// The amount added to total gas fees to make up the total stake rewards (or `null` if the epoch has not finished yet).
        var totalStakeSubsidies: SuiGraphQL.BigInt? { __data["totalStakeSubsidies"] }
        /// The total number of transaction blocks in this epoch.
        ///
        /// If the epoch has not finished yet, this number is computed based on the number of transactions at the latest known checkpoint.
        var totalTransactions: SuiGraphQL.UInt53? { __data["totalTransactions"] }
        /// The storage fund available in this epoch (or `null` if the epoch has not finished yet).
        /// This fund is used to redistribute storage fees from past transactions to future validators.
        var fundSize: SuiGraphQL.BigInt? { __data["fundSize"] }
        /// The epoch's corresponding protocol configuration, including the feature flags and the configuration options.
        var protocolConfigs: ProtocolConfigs? { __data["protocolConfigs"] }
        /// The contents of the system state inner object at the start of this epoch.
        var systemState: SystemState? { __data["systemState"] }
        /// Validator-related properties, including the active validators.
        var validatorSet: ValidatorSet? { __data["validatorSet"] }

        /// Epoch.ProtocolConfigs
        ///
        /// Parent Type: `ProtocolConfigs`
        nonisolated struct ProtocolConfigs: SuiGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.ProtocolConfigs }
          static var __selections: [ApolloAPI.Selection] {
            [
              .field("__typename", String.self),
              .field("protocolVersion", SuiGraphQL.UInt53.self),
            ]
          }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
            [
              GetLatestSuiSystemStateQuery.Data.Epoch.ProtocolConfigs.self
            ]
          }

          var protocolVersion: SuiGraphQL.UInt53 { __data["protocolVersion"] }
        }

        /// Epoch.SystemState
        ///
        /// Parent Type: `MoveValue`
        nonisolated struct SystemState: SuiGraphQL.SelectionSet {
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
              GetLatestSuiSystemStateQuery.Data.Epoch.SystemState.self
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
              GetLatestSuiSystemStateQuery.Data.Epoch.ValidatorSet.self
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
                GetLatestSuiSystemStateQuery.Data.Epoch.ValidatorSet.Contents.self
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
