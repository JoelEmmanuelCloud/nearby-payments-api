// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

extension SuiGraphQL {
  nonisolated struct GetNormalizedMoveStructQuery: GraphQLQuery {
    static let operationName: String = "getNormalizedMoveStruct"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query getNormalizedMoveStruct($packageId: SuiAddress!, $module: String!, $struct: String!) { object(address: $packageId) { __typename asMovePackage { __typename address module(name: $module) { __typename fileFormatVersion struct(name: $struct) { __typename ...RPC_MOVE_STRUCT_FIELDS } } } } }"#,
        fragments: [RPC_MOVE_STRUCT_FIELDS.self]
      ))

    public var packageId: SuiAddress
    public var module: String
    public var `struct`: String

    public init(
      packageId: SuiAddress,
      module: String,
      `struct`: String
    ) {
      self.packageId = packageId
      self.module = module
      self.`struct` = `struct`
    }

    @_spi(Unsafe) public var __variables: Variables? {
      [
        "packageId": packageId,
        "module": module,
        "struct": `struct`,
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
          GetNormalizedMoveStructQuery.Data.self
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
            GetNormalizedMoveStructQuery.Data.Object.self
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
              .field("address", SuiGraphQL.SuiAddress.self),
              .field("module", Module?.self, arguments: ["name": .variable("module")]),
            ]
          }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
            [
              GetNormalizedMoveStructQuery.Data.Object.AsMovePackage.self
            ]
          }

          /// The MovePackage's ID.
          var address: SuiGraphQL.SuiAddress { __data["address"] }
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
                .field("struct", Struct?.self, arguments: ["name": .variable("struct")]),
              ]
            }
            static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
              [
                GetNormalizedMoveStructQuery.Data.Object.AsMovePackage.Module.self
              ]
            }

            /// Bytecode format version.
            var fileFormatVersion: Int? { __data["fileFormatVersion"] }
            /// The struct named `name` in this module.
            var `struct`: Struct? { __data["struct"] }

            /// Object.AsMovePackage.Module.Struct
            ///
            /// Parent Type: `MoveStruct`
            nonisolated struct Struct: SuiGraphQL.SelectionSet {
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
                  GetNormalizedMoveStructQuery.Data.Object.AsMovePackage.Module.Struct.self,
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
        }
      }
    }
  }

}
