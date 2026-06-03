// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

extension SuiGraphQL {
  nonisolated struct RPC_Checkpoint_Fields: SuiGraphQL.SelectionSet, Fragment {
    static var fragmentDefinition: StaticString {
      #"fragment RPC_Checkpoint_Fields on Checkpoint { __typename digest epoch { __typename epochId } rollingGasSummary { __typename computationCost storageCost storageRebate nonRefundableStorageFee } networkTotalTransactions previousCheckpointDigest sequenceNumber timestamp validatorSignatures { __typename signature signersMap } transactions { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename digest } } }"#
    }

    let __data: DataDict
    init(_dataDict: DataDict) { __data = _dataDict }

    static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Checkpoint }
    static var __selections: [ApolloAPI.Selection] {
      [
        .field("__typename", String.self),
        .field("digest", String?.self),
        .field("epoch", Epoch?.self),
        .field("rollingGasSummary", RollingGasSummary?.self),
        .field("networkTotalTransactions", SuiGraphQL.UInt53?.self),
        .field("previousCheckpointDigest", String?.self),
        .field("sequenceNumber", SuiGraphQL.UInt53.self),
        .field("timestamp", SuiGraphQL.DateTime?.self),
        .field("validatorSignatures", ValidatorSignatures?.self),
        .field("transactions", Transactions?.self),
      ]
    }
    static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
      [
        RPC_Checkpoint_Fields.self
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
        ]
      }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
        [
          RPC_Checkpoint_Fields.Epoch.self
        ]
      }

      /// The epoch's id as a sequence number that starts at 0 and is incremented by one at every epoch change.
      var epochId: SuiGraphQL.UInt53 { __data["epochId"] }
    }

    /// RollingGasSummary
    ///
    /// Parent Type: `GasCostSummary`
    nonisolated struct RollingGasSummary: SuiGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.GasCostSummary }
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
          RPC_Checkpoint_Fields.RollingGasSummary.self
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

    /// ValidatorSignatures
    ///
    /// Parent Type: `ValidatorAggregatedSignature`
    nonisolated struct ValidatorSignatures: SuiGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType {
        SuiGraphQL.Objects.ValidatorAggregatedSignature
      }
      static var __selections: [ApolloAPI.Selection] {
        [
          .field("__typename", String.self),
          .field("signature", SuiGraphQL.Base64?.self),
          .field("signersMap", [Int].self),
        ]
      }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
        [
          RPC_Checkpoint_Fields.ValidatorSignatures.self
        ]
      }

      /// The Base64 encoded BLS12381 aggregated signature.
      var signature: SuiGraphQL.Base64? { __data["signature"] }
      /// The indexes of validators that contributed to this signature.
      var signersMap: [Int] { __data["signersMap"] }
    }

    /// Transactions
    ///
    /// Parent Type: `TransactionConnection`
    nonisolated struct Transactions: SuiGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.TransactionConnection }
      static var __selections: [ApolloAPI.Selection] {
        [
          .field("__typename", String.self),
          .field("pageInfo", PageInfo.self),
          .field("nodes", [Node].self),
        ]
      }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
        [
          RPC_Checkpoint_Fields.Transactions.self
        ]
      }

      /// Information to aid in pagination.
      var pageInfo: PageInfo { __data["pageInfo"] }
      /// A list of nodes.
      var nodes: [Node] { __data["nodes"] }

      /// Transactions.PageInfo
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
            RPC_Checkpoint_Fields.Transactions.PageInfo.self
          ]
        }

        /// When paginating forwards, are there more items?
        var hasNextPage: Bool { __data["hasNextPage"] }
        /// When paginating forwards, the cursor to continue.
        var endCursor: String? { __data["endCursor"] }
      }

      /// Transactions.Node
      ///
      /// Parent Type: `Transaction`
      nonisolated struct Node: SuiGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Transaction }
        static var __selections: [ApolloAPI.Selection] {
          [
            .field("__typename", String.self),
            .field("digest", String.self),
          ]
        }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
          [
            RPC_Checkpoint_Fields.Transactions.Node.self
          ]
        }

        /// A 32-byte hash that uniquely identifies the transaction contents, encoded in Base58.
        var digest: String { __data["digest"] }
      }
    }
  }

}
