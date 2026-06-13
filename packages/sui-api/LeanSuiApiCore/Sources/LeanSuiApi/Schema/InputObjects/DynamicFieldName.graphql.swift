// @generated
// This file was automatically generated and should not be edited.

@_spi(Internal) @_spi(Unsafe) import ApolloAPI

extension SuiGraphQL {
  /// A description of a dynamic field's name.
  ///
  /// Names can either be given as serialized `bcs` accompanied by its `type`, or as a Display v2 `literal` expression. Other combinations of inputs are not supported.
  nonisolated struct DynamicFieldName: InputObject {
    private(set) var __data: InputDict

    init(_ data: InputDict) {
      __data = data
    }

    init(
      type: GraphQLNullable<String> = nil,
      bcs: GraphQLNullable<Base64> = nil,
      literal: GraphQLNullable<String> = nil
    ) {
      __data = InputDict([
        "type": type,
        "bcs": bcs,
        "literal": literal,
      ])
    }

    /// The type of the dynamic field's name, like 'u64' or '0x2::kiosk::Listing'.
    var type: GraphQLNullable<String> {
      get { __data["type"] }
      set { __data["type"] = newValue }
    }

    /// The Base64-encoded BCS serialization of the dynamic field's 'name'.
    var bcs: GraphQLNullable<Base64> {
      get { __data["bcs"] }
      set { __data["bcs"] = newValue }
    }

    /// The name represented as a Display v2 literal expression.
    var literal: GraphQLNullable<String> {
      get { __data["literal"] }
      set { __data["literal"] = newValue }
    }
  }

}
