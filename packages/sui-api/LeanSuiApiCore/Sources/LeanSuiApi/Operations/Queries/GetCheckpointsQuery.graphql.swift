// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

extension SuiGraphQL {
  nonisolated struct GetCheckpointsQuery: GraphQLQuery {
    static let operationName: String = "getCheckpoints"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query getCheckpoints($first: Int, $before: String, $last: Int, $after: String) { checkpoints(first: $first, after: $after, last: $last, before: $before) { __typename pageInfo { __typename startCursor endCursor hasNextPage hasPreviousPage } nodes { __typename ...RPC_Checkpoint_Fields } } }"#,
        fragments: [RPC_Checkpoint_Fields.self]
      ))

    public var first: GraphQLNullable<Int32>
    public var before: GraphQLNullable<String>
    public var last: GraphQLNullable<Int32>
    public var after: GraphQLNullable<String>

    public init(
      first: GraphQLNullable<Int32>,
      before: GraphQLNullable<String>,
      last: GraphQLNullable<Int32>,
      after: GraphQLNullable<String>
    ) {
      self.first = first
      self.before = before
      self.last = last
      self.after = after
    }

    @_spi(Unsafe) public var __variables: Variables? {
      [
        "first": first,
        "before": before,
        "last": last,
        "after": after,
      ]
    }

    nonisolated struct Data: SuiGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Query }
      static var __selections: [ApolloAPI.Selection] {
        [
          .field(
            "checkpoints", Checkpoints?.self,
            arguments: [
              "first": .variable("first"),
              "after": .variable("after"),
              "last": .variable("last"),
              "before": .variable("before"),
            ])
        ]
      }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
        [
          GetCheckpointsQuery.Data.self
        ]
      }

      /// Paginate checkpoints in the network, optionally bounded to checkpoints in the given epoch.
      var checkpoints: Checkpoints? { __data["checkpoints"] }

      /// Checkpoints
      ///
      /// Parent Type: `CheckpointConnection`
      nonisolated struct Checkpoints: SuiGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType {
          SuiGraphQL.Objects.CheckpointConnection
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
            GetCheckpointsQuery.Data.Checkpoints.self
          ]
        }

        /// Information to aid in pagination.
        var pageInfo: PageInfo { __data["pageInfo"] }
        /// A list of nodes.
        var nodes: [Node] { __data["nodes"] }

        /// Checkpoints.PageInfo
        ///
        /// Parent Type: `PageInfo`
        nonisolated struct PageInfo: SuiGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.PageInfo }
          static var __selections: [ApolloAPI.Selection] {
            [
              .field("__typename", String.self),
              .field("startCursor", String?.self),
              .field("endCursor", String?.self),
              .field("hasNextPage", Bool.self),
              .field("hasPreviousPage", Bool.self),
            ]
          }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
            [
              GetCheckpointsQuery.Data.Checkpoints.PageInfo.self
            ]
          }

          /// When paginating backwards, the cursor to continue.
          var startCursor: String? { __data["startCursor"] }
          /// When paginating forwards, the cursor to continue.
          var endCursor: String? { __data["endCursor"] }
          /// When paginating forwards, are there more items?
          var hasNextPage: Bool { __data["hasNextPage"] }
          /// When paginating backwards, are there more items?
          var hasPreviousPage: Bool { __data["hasPreviousPage"] }
        }

        /// Checkpoints.Node
        ///
        /// Parent Type: `Checkpoint`
        nonisolated struct Node: SuiGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Checkpoint }
          static var __selections: [ApolloAPI.Selection] {
            [
              .field("__typename", String.self),
              .fragment(RPC_Checkpoint_Fields.self),
            ]
          }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
            [
              GetCheckpointsQuery.Data.Checkpoints.Node.self,
              RPC_Checkpoint_Fields.self,
            ]
          }

          /// A 32-byte hash that uniquely identifies the checkpoint, encoded in Base58. This is a hash of the checkpoint's summary.
          var digest: String? { __data["digest"] }
          /// The epoch that this checkpoint is part of.
          var epoch: Epoch? { __data["epoch"] }
          /// The computation cost, storage cost, storage rebate, and non-refundable storage fee accumulated during this epoch, up to and including this checkpoint. These values increase monotonically across checkpoints in the same epoch, and reset on epoch boundaries.
          var rollingGasSummary: RollingGasSummary? { __data["rollingGasSummary"] }
          /// The total number of transactions in the network by the end of this checkpoint.
          var networkTotalTransactions: SuiGraphQL.UInt53? { __data["networkTotalTransactions"] }
          /// The digest of the previous checkpoint's summary.
          var previousCheckpointDigest: String? { __data["previousCheckpointDigest"] }
          /// The checkpoint's position in the total order of finalized checkpoints, agreed upon by consensus.
          var sequenceNumber: SuiGraphQL.UInt53 { __data["sequenceNumber"] }
          /// The timestamp at which the checkpoint is agreed to have happened according to consensus. Transactions that access time in this checkpoint will observe this timestamp.
          var timestamp: SuiGraphQL.DateTime? { __data["timestamp"] }
          /// The aggregation of signatures from a quorum of validators for the checkpoint proposal.
          var validatorSignatures: ValidatorSignatures? { __data["validatorSignatures"] }
          var transactions: Transactions? { __data["transactions"] }

          struct Fragments: FragmentContainer {
            let __data: DataDict
            init(_dataDict: DataDict) { __data = _dataDict }

            var rPC_Checkpoint_Fields: RPC_Checkpoint_Fields { _toFragment() }
          }

          typealias Epoch = RPC_Checkpoint_Fields.Epoch

          typealias RollingGasSummary = RPC_Checkpoint_Fields.RollingGasSummary

          typealias ValidatorSignatures = RPC_Checkpoint_Fields.ValidatorSignatures

          typealias Transactions = RPC_Checkpoint_Fields.Transactions
        }
      }
    }
  }

}
