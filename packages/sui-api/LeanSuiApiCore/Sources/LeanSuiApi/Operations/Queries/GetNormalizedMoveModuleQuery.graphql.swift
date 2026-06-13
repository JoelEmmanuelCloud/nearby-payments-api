// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

extension SuiGraphQL {
  nonisolated struct GetNormalizedMoveModuleQuery: GraphQLQuery {
    static let operationName: String = "getNormalizedMoveModule"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query getNormalizedMoveModule($packageId: SuiAddress!, $module: String!) { object(address: $packageId) { __typename asMovePackage { __typename module(name: $module) { __typename ...RPC_MOVE_MODULE_FIELDS } } } }"#,
        fragments: [
          RPC_MOVE_ENUM_FIELDS.self, RPC_MOVE_FUNCTION_FIELDS.self, RPC_MOVE_MODULE_FIELDS.self,
          RPC_MOVE_STRUCT_FIELDS.self,
        ]
      ))

    public var packageId: SuiAddress
    public var module: String

    public init(
      packageId: SuiAddress,
      module: String
    ) {
      self.packageId = packageId
      self.module = module
    }

    @_spi(Unsafe) public var __variables: Variables? {
      [
        "packageId": packageId,
        "module": module,
      ]
    }

    nonisolated struct Data: SuiGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Query }
      static var __selections: [ApolloAPI.Selection] {
        [
          .field("object", Object?.self, arguments: ["address": .variable("packageId")])
        ]
      }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
        [
          GetNormalizedMoveModuleQuery.Data.self
        ]
      }

      /// Fetch an object by its address.
      ///
      /// If `version` is specified, the object will be fetched at that exact version.
      ///
      /// If `rootVersion` is specified, the object will be fetched at the latest version at or before this version. Nested dynamic field accesses will also be subject to this bound. This can be used to fetch a child or ancestor object bounded by its root object's version. For any wrapped or child (object-owned) object, its root object can be defined recursively as:
      ///
      /// - The root object of the object it is wrapped in, if it is wrapped.
      /// - The root object of its owner, if it is owned by another object.
      /// - The object itself, if it is not object-owned or wrapped.
      ///
      /// Specifying a `version` or a `rootVersion` disables nested queries for paginating owned objects or dynamic fields (these queries are only supported at checkpoint boundaries).
      ///
      /// If `atCheckpoint` is specified, the object will be fetched at the latest version as of this checkpoint. This will fail if the provided checkpoint is after the RPC's latest checkpoint.
      ///
      /// If none of the above are specified, the object is fetched at the checkpoint being viewed.
      ///
      /// It is an error to specify more than one of `version`, `rootVersion`, or `atCheckpoint`.
      ///
      /// Returns `null` if an object cannot be found that meets this criteria.
      var object: Object? { __data["object"] }

      /// Object
      ///
      /// Parent Type: `Object`
      nonisolated struct Object: SuiGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Object }
        static var __selections: [ApolloAPI.Selection] {
          [
            .field("__typename", String.self),
            .field("asMovePackage", AsMovePackage?.self),
          ]
        }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
          [
            GetNormalizedMoveModuleQuery.Data.Object.self
          ]
        }

        /// Attempts to convert the object into a MovePackage.
        var asMovePackage: AsMovePackage? { __data["asMovePackage"] }

        /// Object.AsMovePackage
        ///
        /// Parent Type: `MovePackage`
        nonisolated struct AsMovePackage: SuiGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.MovePackage }
          static var __selections: [ApolloAPI.Selection] {
            [
              .field("__typename", String.self),
              .field("module", Module?.self, arguments: ["name": .variable("module")]),
            ]
          }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
            [
              GetNormalizedMoveModuleQuery.Data.Object.AsMovePackage.self
            ]
          }

          /// The module named `name` in this package.
          var module: Module? { __data["module"] }

          /// Object.AsMovePackage.Module
          ///
          /// Parent Type: `MoveModule`
          nonisolated struct Module: SuiGraphQL.SelectionSet {
            let __data: DataDict
            init(_dataDict: DataDict) { __data = _dataDict }

            static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.MoveModule }
            static var __selections: [ApolloAPI.Selection] {
              [
                .field("__typename", String.self),
                .fragment(RPC_MOVE_MODULE_FIELDS.self),
              ]
            }
            static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
              [
                GetNormalizedMoveModuleQuery.Data.Object.AsMovePackage.Module.self,
                RPC_MOVE_MODULE_FIELDS.self,
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

            struct Fragments: FragmentContainer {
              let __data: DataDict
              init(_dataDict: DataDict) { __data = _dataDict }

              var rPC_MOVE_MODULE_FIELDS: RPC_MOVE_MODULE_FIELDS { _toFragment() }
            }

            typealias Friends = RPC_MOVE_MODULE_FIELDS.Friends

            typealias Structs = RPC_MOVE_MODULE_FIELDS.Structs

            typealias Enums = RPC_MOVE_MODULE_FIELDS.Enums

            typealias Functions = RPC_MOVE_MODULE_FIELDS.Functions
          }
        }
      }
    }
  }

}
