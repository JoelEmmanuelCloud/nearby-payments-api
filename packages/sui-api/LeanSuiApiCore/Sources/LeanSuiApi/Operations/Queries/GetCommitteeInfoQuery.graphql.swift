// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

extension SuiGraphQL {
  nonisolated struct GetCommitteeInfoQuery: GraphQLQuery {
    static let operationName: String = "getCommitteeInfo"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query getCommitteeInfo($epochId: UInt53) { epoch(epochId: $epochId) { __typename epochId validatorSet { __typename contents { __typename json } } } }"#
      ))

    public var epochId: GraphQLNullable<UInt53>

    public init(epochId: GraphQLNullable<UInt53>) {
      self.epochId = epochId
    }

    @_spi(Unsafe) public var __variables: Variables? { ["epochId": epochId] }

    nonisolated struct Data: SuiGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Query }
      static var __selections: [ApolloAPI.Selection] {
        [
          .field("epoch", Epoch?.self, arguments: ["epochId": .variable("epochId")])
        ]
      }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
        [
          GetCommitteeInfoQuery.Data.self
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
            .field("validatorSet", ValidatorSet?.self),
          ]
        }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
          [
            GetCommitteeInfoQuery.Data.Epoch.self
          ]
        }

        /// The epoch's id as a sequence number that starts at 0 and is incremented by one at every epoch change.
        var epochId: SuiGraphQL.UInt53 { __data["epochId"] }
        /// Validator-related properties, including the active validators.
        var validatorSet: ValidatorSet? { __data["validatorSet"] }

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
              GetCommitteeInfoQuery.Data.Epoch.ValidatorSet.self
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
                GetCommitteeInfoQuery.Data.Epoch.ValidatorSet.Contents.self
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
