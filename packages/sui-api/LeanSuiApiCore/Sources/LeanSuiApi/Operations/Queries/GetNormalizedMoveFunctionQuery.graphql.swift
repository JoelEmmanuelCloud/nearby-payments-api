// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

extension SuiGraphQL {
  nonisolated struct GetNormalizedMoveFunctionQuery: GraphQLQuery {
    static let operationName: String = "getNormalizedMoveFunction"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query getNormalizedMoveFunction($packageId: SuiAddress!, $module: String!, $function: String!) { object(address: $packageId) { __typename address asMovePackage { __typename module(name: $module) { __typename fileFormatVersion function(name: $function) { __typename ...RPC_MOVE_FUNCTION_FIELDS } } } } }"#,
        fragments: [RPC_MOVE_FUNCTION_FIELDS.self]
      ))

    public var packageId: SuiAddress
    public var module: String
    public var function: String

    public init(
      packageId: SuiAddress,
      module: String,
      function: String
    ) {
      self.packageId = packageId
      self.module = module
      self.function = function
    }

    @_spi(Unsafe) public var __variables: Variables? {
      [
        "packageId": packageId,
        "module": module,
        "function": function,
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
          GetNormalizedMoveFunctionQuery.Data.self
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
            .field("address", SuiGraphQL.SuiAddress.self),
            .field("asMovePackage", AsMovePackage?.self),
          ]
        }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
          [
            GetNormalizedMoveFunctionQuery.Data.Object.self
          ]
        }

        /// The Object's ID.
        var address: SuiGraphQL.SuiAddress { __data["address"] }
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
              GetNormalizedMoveFunctionQuery.Data.Object.AsMovePackage.self
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
                .field("fileFormatVersion", Int?.self),
                .field("function", Function?.self, arguments: ["name": .variable("function")]),
              ]
            }
            static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
              [
                GetNormalizedMoveFunctionQuery.Data.Object.AsMovePackage.Module.self
              ]
            }

            /// Bytecode format version.
            var fileFormatVersion: Int? { __data["fileFormatVersion"] }
            /// The function named `name` in this module.
            var function: Function? { __data["function"] }

            /// Object.AsMovePackage.Module.Function
            ///
            /// Parent Type: `MoveFunction`
            nonisolated struct Function: SuiGraphQL.SelectionSet {
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
                  GetNormalizedMoveFunctionQuery.Data.Object.AsMovePackage.Module.Function.self,
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
    }
  }

}
