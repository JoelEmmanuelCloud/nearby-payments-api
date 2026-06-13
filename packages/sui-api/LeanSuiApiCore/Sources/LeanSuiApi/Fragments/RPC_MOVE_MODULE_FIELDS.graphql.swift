// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

extension SuiGraphQL {
  nonisolated struct RPC_MOVE_MODULE_FIELDS: SuiGraphQL.SelectionSet, Fragment {
    static var fragmentDefinition: StaticString {
      #"fragment RPC_MOVE_MODULE_FIELDS on MoveModule { __typename name friends { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename name package { __typename address } } } structs { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename ...RPC_MOVE_STRUCT_FIELDS } } enums { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename ...RPC_MOVE_ENUM_FIELDS } } fileFormatVersion functions { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename ...RPC_MOVE_FUNCTION_FIELDS } } }"#
    }

    let __data: DataDict
    init(_dataDict: DataDict) { __data = _dataDict }

    static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.MoveModule }
    static var __selections: [ApolloAPI.Selection] {
      [
        .field("__typename", String.self),
        .field("name", String.self),
        .field("friends", Friends?.self),
        .field("structs", Structs?.self),
        .field("enums", Enums?.self),
        .field("fileFormatVersion", Int?.self),
        .field("functions", Functions?.self),
      ]
    }
    static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
      [
        RPC_MOVE_MODULE_FIELDS.self
      ]
    }

    /// The module's unqualified name.
    var name: String { __data["name"] }
    /// Modules that this module considers friends. These modules can call `public(package)` functions in this module.
    var friends: Friends? { __data["friends"] }
    /// Paginate through this module's struct definitions.
    var structs: Structs? { __data["structs"] }
    /// Paginate through this module's enum definitions.
    var enums: Enums? { __data["enums"] }
    /// Bytecode format version.
    var fileFormatVersion: Int? { __data["fileFormatVersion"] }
    /// Paginate through this module's function definitions.
    var functions: Functions? { __data["functions"] }

    /// Friends
    ///
    /// Parent Type: `MoveModuleConnection`
    nonisolated struct Friends: SuiGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.MoveModuleConnection }
      static var __selections: [ApolloAPI.Selection] {
        [
          .field("__typename", String.self),
          .field("pageInfo", PageInfo.self),
          .field("nodes", [Node].self),
        ]
      }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
        [
          RPC_MOVE_MODULE_FIELDS.Friends.self
        ]
      }

      /// Information to aid in pagination.
      var pageInfo: PageInfo { __data["pageInfo"] }
      /// A list of nodes.
      var nodes: [Node] { __data["nodes"] }

      /// Friends.PageInfo
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
            RPC_MOVE_MODULE_FIELDS.Friends.PageInfo.self
          ]
        }

        /// When paginating forwards, are there more items?
        var hasNextPage: Bool { __data["hasNextPage"] }
        /// When paginating forwards, the cursor to continue.
        var endCursor: String? { __data["endCursor"] }
      }

      /// Friends.Node
      ///
      /// Parent Type: `MoveModule`
      nonisolated struct Node: SuiGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.MoveModule }
        static var __selections: [ApolloAPI.Selection] {
          [
            .field("__typename", String.self),
            .field("name", String.self),
            .field("package", Package?.self),
          ]
        }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
          [
            RPC_MOVE_MODULE_FIELDS.Friends.Node.self
          ]
        }

        /// The module's unqualified name.
        var name: String { __data["name"] }
        /// The package that this module was defined in.
        var package: Package? { __data["package"] }

        /// Friends.Node.Package
        ///
        /// Parent Type: `MovePackage`
        nonisolated struct Package: SuiGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.MovePackage }
          static var __selections: [ApolloAPI.Selection] {
            [
              .field("__typename", String.self),
              .field("address", SuiGraphQL.SuiAddress.self),
            ]
          }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
            [
              RPC_MOVE_MODULE_FIELDS.Friends.Node.Package.self
            ]
          }

          /// The MovePackage's ID.
          var address: SuiGraphQL.SuiAddress { __data["address"] }
        }
      }
    }

    /// Structs
    ///
    /// Parent Type: `MoveStructConnection`
    nonisolated struct Structs: SuiGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.MoveStructConnection }
      static var __selections: [ApolloAPI.Selection] {
        [
          .field("__typename", String.self),
          .field("pageInfo", PageInfo.self),
          .field("nodes", [Node].self),
        ]
      }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
        [
          RPC_MOVE_MODULE_FIELDS.Structs.self
        ]
      }

      /// Information to aid in pagination.
      var pageInfo: PageInfo { __data["pageInfo"] }
      /// A list of nodes.
      var nodes: [Node] { __data["nodes"] }

      /// Structs.PageInfo
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
            RPC_MOVE_MODULE_FIELDS.Structs.PageInfo.self
          ]
        }

        /// When paginating forwards, are there more items?
        var hasNextPage: Bool { __data["hasNextPage"] }
        /// When paginating forwards, the cursor to continue.
        var endCursor: String? { __data["endCursor"] }
      }

      /// Structs.Node
      ///
      /// Parent Type: `MoveStruct`
      nonisolated struct Node: SuiGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.MoveStruct }
        static var __selections: [ApolloAPI.Selection] {
          [
            .field("__typename", String.self),
            .fragment(RPC_MOVE_STRUCT_FIELDS.self),
          ]
        }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
          [
            RPC_MOVE_MODULE_FIELDS.Structs.Node.self,
            RPC_MOVE_STRUCT_FIELDS.self,
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

        struct Fragments: FragmentContainer {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          var rPC_MOVE_STRUCT_FIELDS: RPC_MOVE_STRUCT_FIELDS { _toFragment() }
        }

        typealias Field = RPC_MOVE_STRUCT_FIELDS.Field

        typealias TypeParameter = RPC_MOVE_STRUCT_FIELDS.TypeParameter
      }
    }

    /// Enums
    ///
    /// Parent Type: `MoveEnumConnection`
    nonisolated struct Enums: SuiGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.MoveEnumConnection }
      static var __selections: [ApolloAPI.Selection] {
        [
          .field("__typename", String.self),
          .field("pageInfo", PageInfo.self),
          .field("nodes", [Node].self),
        ]
      }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
        [
          RPC_MOVE_MODULE_FIELDS.Enums.self
        ]
      }

      /// Information to aid in pagination.
      var pageInfo: PageInfo { __data["pageInfo"] }
      /// A list of nodes.
      var nodes: [Node] { __data["nodes"] }

      /// Enums.PageInfo
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
            RPC_MOVE_MODULE_FIELDS.Enums.PageInfo.self
          ]
        }

        /// When paginating forwards, are there more items?
        var hasNextPage: Bool { __data["hasNextPage"] }
        /// When paginating forwards, the cursor to continue.
        var endCursor: String? { __data["endCursor"] }
      }

      /// Enums.Node
      ///
      /// Parent Type: `MoveEnum`
      nonisolated struct Node: SuiGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.MoveEnum }
        static var __selections: [ApolloAPI.Selection] {
          [
            .field("__typename", String.self),
            .fragment(RPC_MOVE_ENUM_FIELDS.self),
          ]
        }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
          [
            RPC_MOVE_MODULE_FIELDS.Enums.Node.self,
            RPC_MOVE_ENUM_FIELDS.self,
          ]
        }

        /// The enum's unqualified name.
        var name: String { __data["name"] }
        /// Abilities on this enum definition.
        var abilities: [GraphQLEnum<SuiGraphQL.MoveAbility>]? { __data["abilities"] }
        /// Constraints on the enum's formal type parameters.
        ///
        /// Move bytecode does not name type parameters, so when they are referenced (e.g. in field types), they are identified by their index in this list.
        var typeParameters: [TypeParameter]? { __data["typeParameters"] }
        /// The names and fields of the enum's variants
        ///
        /// Field types reference type parameters by their index in the defining enum's `typeParameters` list.
        var variants: [Variant]? { __data["variants"] }

        struct Fragments: FragmentContainer {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          var rPC_MOVE_ENUM_FIELDS: RPC_MOVE_ENUM_FIELDS { _toFragment() }
        }

        typealias TypeParameter = RPC_MOVE_ENUM_FIELDS.TypeParameter

        typealias Variant = RPC_MOVE_ENUM_FIELDS.Variant
      }
    }

    /// Functions
    ///
    /// Parent Type: `MoveFunctionConnection`
    nonisolated struct Functions: SuiGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType {
        SuiGraphQL.Objects.MoveFunctionConnection
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
          RPC_MOVE_MODULE_FIELDS.Functions.self
        ]
      }

      /// Information to aid in pagination.
      var pageInfo: PageInfo { __data["pageInfo"] }
      /// A list of nodes.
      var nodes: [Node] { __data["nodes"] }

      /// Functions.PageInfo
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
            RPC_MOVE_MODULE_FIELDS.Functions.PageInfo.self
          ]
        }

        /// When paginating forwards, are there more items?
        var hasNextPage: Bool { __data["hasNextPage"] }
        /// When paginating forwards, the cursor to continue.
        var endCursor: String? { __data["endCursor"] }
      }

      /// Functions.Node
      ///
      /// Parent Type: `MoveFunction`
      nonisolated struct Node: SuiGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.MoveFunction }
        static var __selections: [ApolloAPI.Selection] {
          [
            .field("__typename", String.self),
            .fragment(RPC_MOVE_FUNCTION_FIELDS.self),
          ]
        }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
          [
            RPC_MOVE_MODULE_FIELDS.Functions.Node.self,
            RPC_MOVE_FUNCTION_FIELDS.self,
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

        struct Fragments: FragmentContainer {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          var rPC_MOVE_FUNCTION_FIELDS: RPC_MOVE_FUNCTION_FIELDS { _toFragment() }
        }

        typealias Parameter = RPC_MOVE_FUNCTION_FIELDS.Parameter

        typealias TypeParameter = RPC_MOVE_FUNCTION_FIELDS.TypeParameter

        typealias Return = RPC_MOVE_FUNCTION_FIELDS.Return
      }
    }
  }

}
