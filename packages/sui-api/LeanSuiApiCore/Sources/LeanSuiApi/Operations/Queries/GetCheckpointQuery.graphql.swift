// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

extension SuiGraphQL {
  nonisolated struct GetCheckpointQuery: GraphQLQuery {
    static let operationName: String = "getCheckpoint"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query getCheckpoint($sequenceNumber: UInt53) { checkpoint(sequenceNumber: $sequenceNumber) { __typename ...RPC_Checkpoint_Fields } }"#,
        fragments: [RPC_Checkpoint_Fields.self]
      ))

    public var sequenceNumber: GraphQLNullable<UInt53>

    public init(sequenceNumber: GraphQLNullable<UInt53>) {
      self.sequenceNumber = sequenceNumber
    }

    @_spi(Unsafe) public var __variables: Variables? { ["sequenceNumber": sequenceNumber] }

    nonisolated struct Data: SuiGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Query }
      static var __selections: [ApolloAPI.Selection] {
        [
          .field(
            "checkpoint", Checkpoint?.self,
            arguments: ["sequenceNumber": .variable("sequenceNumber")])
        ]
      }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
        [
          GetCheckpointQuery.Data.self
        ]
      }

      /// Fetch a checkpoint by its sequence number, or the latest checkpoint if no sequence number is provided.
      ///
      /// Returns `null` if the checkpoint does not exist in the store, either because it never existed or because it was pruned.
      var checkpoint: Checkpoint? { __data["checkpoint"] }

      /// Checkpoint
      ///
      /// Parent Type: `Checkpoint`
      nonisolated struct Checkpoint: SuiGraphQL.SelectionSet {
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
            GetCheckpointQuery.Data.Checkpoint.self,
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
