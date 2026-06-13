// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

extension SuiGraphQL {
  nonisolated struct RPC_MOVE_FUNCTION_FIELDS: SuiGraphQL.SelectionSet, Fragment {
    static var fragmentDefinition: StaticString {
      #"fragment RPC_MOVE_FUNCTION_FIELDS on MoveFunction { __typename name visibility isEntry parameters { __typename signature } typeParameters { __typename constraints } return { __typename repr signature } }"#
    }

    let __data: DataDict
    init(_dataDict: DataDict) { __data = _dataDict }

    static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.MoveFunction }
    static var __selections: [ApolloAPI.Selection] {
      [
        .field("__typename", String.self),
        .field("name", String.self),
        .field("visibility", GraphQLEnum<SuiGraphQL.MoveVisibility>?.self),
        .field("isEntry", Bool?.self),
        .field("parameters", [Parameter]?.self),
        .field("typeParameters", [TypeParameter]?.self),
        .field("return", [Return]?.self),
      ]
    }
    static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
      [
        RPC_MOVE_FUNCTION_FIELDS.self
      ]
    }

    /// The function's unqualified name.
    var name: String { __data["name"] }
    /// The function's visibility: `public`, `public(friend)`, or `private`.
    var visibility: GraphQLEnum<SuiGraphQL.MoveVisibility>? { __data["visibility"] }
    /// Whether the function is marked `entry` or not.
    var isEntry: Bool? { __data["isEntry"] }
    /// The function's parameter types. These types can reference type parameters introduced by this function (see `typeParameters`).
    var parameters: [Parameter]? { __data["parameters"] }
    /// Constraints on the function's formal type parameters.
    ///
    /// Move bytecode does not name type parameters, so when they are referenced (e.g. in parameter and return types), they are identified by their index in this list.
    var typeParameters: [TypeParameter]? { __data["typeParameters"] }
    /// The function's return types. There can be multiple because functions in Move can return multiple values. These types can reference type parameters introduced by this function (see `typeParameters`).
    var `return`: [Return]? { __data["return"] }

    /// Parameter
    ///
    /// Parent Type: `OpenMoveType`
    nonisolated struct Parameter: SuiGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.OpenMoveType }
      static var __selections: [ApolloAPI.Selection] {
        [
          .field("__typename", String.self),
          .field("signature", SuiGraphQL.OpenMoveTypeSignature.self),
        ]
      }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
        [
          RPC_MOVE_FUNCTION_FIELDS.Parameter.self
        ]
      }

      /// Structured representation of the type signature.
      var signature: SuiGraphQL.OpenMoveTypeSignature { __data["signature"] }
    }

    /// TypeParameter
    ///
    /// Parent Type: `MoveFunctionTypeParameter`
    nonisolated struct TypeParameter: SuiGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType {
        SuiGraphQL.Objects.MoveFunctionTypeParameter
      }
      static var __selections: [ApolloAPI.Selection] {
        [
          .field("__typename", String.self),
          .field("constraints", [GraphQLEnum<SuiGraphQL.MoveAbility>].self),
        ]
      }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
        [
          RPC_MOVE_FUNCTION_FIELDS.TypeParameter.self
        ]
      }

      /// Ability constraints on this type parameter.
      var constraints: [GraphQLEnum<SuiGraphQL.MoveAbility>] { __data["constraints"] }
    }

    /// Return
    ///
    /// Parent Type: `OpenMoveType`
    nonisolated struct Return: SuiGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.OpenMoveType }
      static var __selections: [ApolloAPI.Selection] {
        [
          .field("__typename", String.self),
          .field("repr", String.self),
          .field("signature", SuiGraphQL.OpenMoveTypeSignature.self),
        ]
      }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
        [
          RPC_MOVE_FUNCTION_FIELDS.Return.self
        ]
      }

      /// Flat representation of the type signature, as a displayable string.
      var repr: String { __data["repr"] }
      /// Structured representation of the type signature.
      var signature: SuiGraphQL.OpenMoveTypeSignature { __data["signature"] }
    }
  }

}
