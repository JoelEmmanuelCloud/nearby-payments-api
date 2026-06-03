// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

extension SuiGraphQL {
  nonisolated struct GetNormalizedMoveModulesByPackageQuery: GraphQLQuery {
    static let operationName: String = "getNormalizedMoveModulesByPackage"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query getNormalizedMoveModulesByPackage($packageId: SuiAddress!, $cursor: String) { object(address: $packageId) { __typename asMovePackage { __typename address modules(after: $cursor) { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename ...RPC_MOVE_MODULE_FIELDS } } } } }"#,
        fragments: [
          RPC_MOVE_ENUM_FIELDS.self, RPC_MOVE_FUNCTION_FIELDS.self, RPC_MOVE_MODULE_FIELDS.self,
          RPC_MOVE_STRUCT_FIELDS.self,
        ]
      ))

    public var packageId: SuiAddress
    public var cursor: GraphQLNullable<String>

    public init(
      packageId: SuiAddress,
      cursor: GraphQLNullable<String>
    ) {
      self.packageId = packageId
      self.cursor = cursor
    }

    @_spi(Unsafe) public var __variables: Variables? {
      [
        "packageId": packageId,
        "cursor": cursor,
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
          GetNormalizedMoveModulesByPackageQuery.Data.self
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
            GetNormalizedMoveModulesByPackageQuery.Data.Object.self
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
              .field("modules", Modules?.self, arguments: ["after": .variable("cursor")]),
            ]
          }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
            [
              GetNormalizedMoveModulesByPackageQuery.Data.Object.AsMovePackage.self
            ]
          }

          /// The MovePackage's ID.
          var address: SuiGraphQL.SuiAddress { __data["address"] }
          /// Paginate through this package's modules.
          var modules: Modules? { __data["modules"] }

          /// Object.AsMovePackage.Modules
          ///
          /// Parent Type: `MoveModuleConnection`
          nonisolated struct Modules: SuiGraphQL.SelectionSet {
            let __data: DataDict
            init(_dataDict: DataDict) { __data = _dataDict }

            static var __parentType: any ApolloAPI.ParentType {
              SuiGraphQL.Objects.MoveModuleConnection
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
                GetNormalizedMoveModulesByPackageQuery.Data.Object.AsMovePackage.Modules.self
              ]
            }

            /// Information to aid in pagination.
            var pageInfo: PageInfo { __data["pageInfo"] }
            /// A list of nodes.
            var nodes: [Node] { __data["nodes"] }

            /// Object.AsMovePackage.Modules.PageInfo
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
                  GetNormalizedMoveModulesByPackageQuery.Data.Object.AsMovePackage.Modules.PageInfo
                    .self
                ]
              }

              /// When paginating forwards, are there more items?
              var hasNextPage: Bool { __data["hasNextPage"] }
              /// When paginating forwards, the cursor to continue.
              var endCursor: String? { __data["endCursor"] }
            }

            /// Object.AsMovePackage.Modules.Node
            ///
            /// Parent Type: `MoveModule`
            nonisolated struct Node: SuiGraphQL.SelectionSet {
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
                  GetNormalizedMoveModulesByPackageQuery.Data.Object.AsMovePackage.Modules.Node
                    .self,
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

}
