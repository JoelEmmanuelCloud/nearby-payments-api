// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

extension SuiGraphQL {
  nonisolated struct EventFilter: InputObject {
    private(set) var __data: InputDict

    init(_ data: InputDict) {
      __data = data
    }

    init(
      afterCheckpoint: GraphQLNullable<UInt53> = nil,
      atCheckpoint: GraphQLNullable<UInt53> = nil,
      beforeCheckpoint: GraphQLNullable<UInt53> = nil,
      sender: GraphQLNullable<SuiAddress> = nil,
      module: GraphQLNullable<String> = nil,
      type: GraphQLNullable<String> = nil
    ) {
      __data = InputDict([
        "afterCheckpoint": afterCheckpoint,
        "atCheckpoint": atCheckpoint,
        "beforeCheckpoint": beforeCheckpoint,
        "sender": sender,
        "module": module,
        "type": type,
      ])
    }

    /// Limit to events that occured strictly after the given checkpoint.
    var afterCheckpoint: GraphQLNullable<UInt53> {
      get { __data["afterCheckpoint"] }
      set { __data["afterCheckpoint"] = newValue }
    }

    /// Limit to events in the given checkpoint.
    var atCheckpoint: GraphQLNullable<UInt53> {
      get { __data["atCheckpoint"] }
      set { __data["atCheckpoint"] = newValue }
    }

    /// Limit to event that occured strictly before the given checkpoint.
    var beforeCheckpoint: GraphQLNullable<UInt53> {
      get { __data["beforeCheckpoint"] }
      set { __data["beforeCheckpoint"] = newValue }
    }

    /// Filter on events by transaction sender address.
    var sender: GraphQLNullable<SuiAddress> {
      get { __data["sender"] }
      set { __data["sender"] = newValue }
    }

    /// Events emitted by a particular module. An event is emitted by a particular module if some function in the module is called by a PTB and emits an event.
    ///
    /// Modules can be filtered by their package, or package::module. We currently do not support filtering by emitting module and event type at the same time so if both are provided in one filter, the query will error.
    var module: GraphQLNullable<String> {
      get { __data["module"] }
      set { __data["module"] = newValue }
    }

    /// This field is used to specify the type of event emitted.
    ///
    /// Events can be filtered by their type's package, package::module, or their fully qualified type name.
    ///
    /// Generic types can be queried by either the generic type name, e.g. `0x2::coin::Coin`, or by the full type name, such as `0x2::coin::Coin<0x2::sui::SUI>`.
    var type: GraphQLNullable<String> {
      get { __data["type"] }
      set { __data["type"] = newValue }
    }
  }

}
