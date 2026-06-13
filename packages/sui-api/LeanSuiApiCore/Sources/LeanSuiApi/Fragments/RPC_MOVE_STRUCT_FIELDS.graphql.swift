// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

extension SuiGraphQL {
  nonisolated struct RPC_MOVE_STRUCT_FIELDS: SuiGraphQL.SelectionSet, Fragment {
    static var fragmentDefinition: StaticString {
      #"fragment RPC_MOVE_STRUCT_FIELDS on MoveStruct { __typename name abilities fields { __typename name type { __typename signature } } typeParameters { __typename isPhantom constraints } }"#
    }

    let __data: DataDict
    init(_dataDict: DataDict) { __data = _dataDict }

    static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.MoveStruct }
    static var __selections: [ApolloAPI.Selection] {
      [
        .field("__typename", String.self),
        .field("name", String.self),
        .field("abilities", [GraphQLEnum<SuiGraphQL.MoveAbility>]?.self),
        .field("fields", [Field]?.self),
        .field("typeParameters", [TypeParameter]?.self),
      ]
    }
    static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
      [
        RPC_MOVE_STRUCT_FIELDS.self
      ]
    }

    /// The struct's unqualified name.
    var name: String { __data["name"] }
    /// Abilities on this struct definition.
    var abilities: [GraphQLEnum<SuiGraphQL.MoveAbility>]? { __data["abilities"] }
    /// The names and types of the struct's fields.
    ///
    /// Field types reference type parameters by their index in the defining struct's `typeParameters` list.
    var fields: [Field]? { __data["fields"] }
    /// Constraints on the struct's formal type parameters.
    ///
    /// Move bytecode does not name type parameters, so when they are referenced (e.g. in field types), they are identified by their index in this list.
    var typeParameters: [TypeParameter]? { __data["typeParameters"] }

    /// Field
    ///
    /// Parent Type: `MoveField`
    nonisolated struct Field: SuiGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.MoveField }
      static var __selections: [ApolloAPI.Selection] {
        [
          .field("__typename", String.self),
          .field("name", String?.self),
          .field("type", Type_SelectionSet?.self),
        ]
      }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
        [
          RPC_MOVE_STRUCT_FIELDS.Field.self
        ]
      }

      /// The field's name.
      var name: String? { __data["name"] }
      /// The field's type.
      ///
      /// This type can reference type parameters introduced by the defining struct (see `typeParameters`).
      var type: Type_SelectionSet? { __data["type"] }

      /// Field.Type_SelectionSet
      ///
      /// Parent Type: `OpenMoveType`
      nonisolated struct Type_SelectionSet: SuiGraphQL.SelectionSet {
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
            RPC_MOVE_STRUCT_FIELDS.Field.Type_SelectionSet.self
          ]
        }

        /// Structured representation of the type signature.
        var signature: SuiGraphQL.OpenMoveTypeSignature { __data["signature"] }
      }
    }

    /// TypeParameter
    ///
    /// Parent Type: `MoveDatatypeTypeParameter`
    nonisolated struct TypeParameter: SuiGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType {
        SuiGraphQL.Objects.MoveDatatypeTypeParameter
      }
      static var __selections: [ApolloAPI.Selection] {
        [
          .field("__typename", String.self),
          .field("isPhantom", Bool.self),
          .field("constraints", [GraphQLEnum<SuiGraphQL.MoveAbility>].self),
        ]
      }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
        [
          RPC_MOVE_STRUCT_FIELDS.TypeParameter.self
        ]
      }

      /// Whether this type parameter is marked `phantom` or not.
      ///
      /// Phantom type parameters are not referenced in the struct's fields.
      var isPhantom: Bool { __data["isPhantom"] }
      /// Ability constraints on this type parameter.
      var constraints: [GraphQLEnum<SuiGraphQL.MoveAbility>] { __data["constraints"] }
    }
  }

}
