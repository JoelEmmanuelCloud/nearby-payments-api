// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

extension SuiGraphQL {
  nonisolated struct TransactionFilter: InputObject {
    private(set) var __data: InputDict

    init(_ data: InputDict) {
      __data = data
    }

    init(
      afterCheckpoint: GraphQLNullable<UInt53> = nil,
      atCheckpoint: GraphQLNullable<UInt53> = nil,
      beforeCheckpoint: GraphQLNullable<UInt53> = nil,
      function: GraphQLNullable<String> = nil,
      kind: GraphQLNullable<GraphQLEnum<TransactionKindInput>> = nil,
      affectedAddress: GraphQLNullable<SuiAddress> = nil,
      affectedObject: GraphQLNullable<SuiAddress> = nil,
      sentAddress: GraphQLNullable<SuiAddress> = nil
    ) {
      __data = InputDict([
        "afterCheckpoint": afterCheckpoint,
        "atCheckpoint": atCheckpoint,
        "beforeCheckpoint": beforeCheckpoint,
        "function": function,
        "kind": kind,
        "affectedAddress": affectedAddress,
        "affectedObject": affectedObject,
        "sentAddress": sentAddress,
      ])
    }

    /// Filter to transactions that occurred strictly after the given checkpoint.
    var afterCheckpoint: GraphQLNullable<UInt53> {
      get { __data["afterCheckpoint"] }
      set { __data["afterCheckpoint"] = newValue }
    }

    /// Filter to transactions in the given checkpoint.
    var atCheckpoint: GraphQLNullable<UInt53> {
      get { __data["atCheckpoint"] }
      set { __data["atCheckpoint"] = newValue }
    }

    /// Filter to transaction that occurred strictly before the given checkpoint.
    var beforeCheckpoint: GraphQLNullable<UInt53> {
      get { __data["beforeCheckpoint"] }
      set { __data["beforeCheckpoint"] = newValue }
    }

    /// Filter transactions by move function called. Calls can be filtered by the `package`, `package::module`, or the `package::module::name` of their function.
    var function: GraphQLNullable<String> {
      get { __data["function"] }
      set { __data["function"] = newValue }
    }

    /// An input filter selecting for either system or programmable transactions.
    var kind: GraphQLNullable<GraphQLEnum<TransactionKindInput>> {
      get { __data["kind"] }
      set { __data["kind"] = newValue }
    }

    /// Limit to transactions that interacted with the given address.
    /// The address could be a sender, sponsor, or recipient of the transaction.
    var affectedAddress: GraphQLNullable<SuiAddress> {
      get { __data["affectedAddress"] }
      set { __data["affectedAddress"] = newValue }
    }

    /// Limit to transactions that interacted with the given object.
    /// The object could have been created, read, modified, deleted, wrapped, or unwrapped by the transaction.
    /// Objects that were passed as a `Receiving` input are not considered to have been affected by a transaction unless they were actually received.
    var affectedObject: GraphQLNullable<SuiAddress> {
      get { __data["affectedObject"] }
      set { __data["affectedObject"] = newValue }
    }

    /// Limit to transactions that were sent by the given address.
    var sentAddress: GraphQLNullable<SuiAddress> {
      get { __data["sentAddress"] }
      set { __data["sentAddress"] = newValue }
    }
  }

}
