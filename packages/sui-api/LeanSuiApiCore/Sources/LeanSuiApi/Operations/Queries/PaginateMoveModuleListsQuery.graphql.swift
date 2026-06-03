// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

extension SuiGraphQL {
  nonisolated struct PaginateMoveModuleListsQuery: GraphQLQuery {
    static let operationName: String = "paginateMoveModuleLists"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query paginateMoveModuleLists($packageId: SuiAddress!, $module: String!, $hasMoreFriends: Boolean!, $hasMoreStructs: Boolean!, $hasMoreFunctions: Boolean!, $hasMoreEnums: Boolean!, $afterFriends: String, $afterStructs: String, $afterFunctions: String, $afterEnums: String) { object(address: $packageId) { __typename asMovePackage { __typename module(name: $module) { __typename friends(after: $afterFriends) @include(if: $hasMoreFriends) { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename name package { __typename address } } } structs(after: $afterStructs) @include(if: $hasMoreStructs) { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename ...RPC_MOVE_STRUCT_FIELDS } } enums(after: $afterEnums) @include(if: $hasMoreEnums) { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename ...RPC_MOVE_ENUM_FIELDS } } functions(after: $afterFunctions) @include(if: $hasMoreFunctions) { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename ...RPC_MOVE_FUNCTION_FIELDS } } } } } }"#,
        fragments: [
          RPC_MOVE_ENUM_FIELDS.self, RPC_MOVE_FUNCTION_FIELDS.self, RPC_MOVE_STRUCT_FIELDS.self,
        ]
      ))

    public var packageId: SuiAddress
    public var module: String
    public var hasMoreFriends: Bool
    public var hasMoreStructs: Bool
    public var hasMoreFunctions: Bool
    public var hasMoreEnums: Bool
    public var afterFriends: GraphQLNullable<String>
    public var afterStructs: GraphQLNullable<String>
    public var afterFunctions: GraphQLNullable<String>
    public var afterEnums: GraphQLNullable<String>

    public init(
      packageId: SuiAddress,
      module: String,
      hasMoreFriends: Bool,
      hasMoreStructs: Bool,
      hasMoreFunctions: Bool,
      hasMoreEnums: Bool,
      afterFriends: GraphQLNullable<String>,
      afterStructs: GraphQLNullable<String>,
      afterFunctions: GraphQLNullable<String>,
      afterEnums: GraphQLNullable<String>
    ) {
      self.packageId = packageId
      self.module = module
      self.hasMoreFriends = hasMoreFriends
      self.hasMoreStructs = hasMoreStructs
      self.hasMoreFunctions = hasMoreFunctions
      self.hasMoreEnums = hasMoreEnums
      self.afterFriends = afterFriends
      self.afterStructs = afterStructs
      self.afterFunctions = afterFunctions
      self.afterEnums = afterEnums
    }

    @_spi(Unsafe) public var __variables: Variables? {
      [
        "packageId": packageId,
        "module": module,
        "hasMoreFriends": hasMoreFriends,
        "hasMoreStructs": hasMoreStructs,
        "hasMoreFunctions": hasMoreFunctions,
        "hasMoreEnums": hasMoreEnums,
        "afterFriends": afterFriends,
        "afterStructs": afterStructs,
        "afterFunctions": afterFunctions,
        "afterEnums": afterEnums,
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
          PaginateMoveModuleListsQuery.Data.self
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
            PaginateMoveModuleListsQuery.Data.Object.self
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
              PaginateMoveModuleListsQuery.Data.Object.AsMovePackage.self
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
                .include(
                  if: "hasMoreFriends",
                  .field("friends", Friends?.self, arguments: ["after": .variable("afterFriends")])),
                .include(
                  if: "hasMoreStructs",
                  .field("structs", Structs?.self, arguments: ["after": .variable("afterStructs")])),
                .include(
                  if: "hasMoreEnums",
                  .field("enums", Enums?.self, arguments: ["after": .variable("afterEnums")])),
                .include(
                  if: "hasMoreFunctions",
                  .field(
                    "functions", Functions?.self, arguments: ["after": .variable("afterFunctions")])
                ),
              ]
            }
            static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
              [
                PaginateMoveModuleListsQuery.Data.Object.AsMovePackage.Module.self
              ]
            }

            /// Modules that this module considers friends. These modules can call `public(package)` functions in this module.
            var friends: Friends? { __data["friends"] }
            /// Paginate through this module's struct definitions.
            var structs: Structs? { __data["structs"] }
            /// Paginate through this module's enum definitions.
            var enums: Enums? { __data["enums"] }
            /// Paginate through this module's function definitions.
            var functions: Functions? { __data["functions"] }

            /// Object.AsMovePackage.Module.Friends
            ///
            /// Parent Type: `MoveModuleConnection`
            nonisolated struct Friends: SuiGraphQL.SelectionSet {
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
                  PaginateMoveModuleListsQuery.Data.Object.AsMovePackage.Module.Friends.self
                ]
              }

              /// Information to aid in pagination.
              var pageInfo: PageInfo { __data["pageInfo"] }
              /// A list of nodes.
              var nodes: [Node] { __data["nodes"] }

              /// Object.AsMovePackage.Module.Friends.PageInfo
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
                    PaginateMoveModuleListsQuery.Data.Object.AsMovePackage.Module.Friends.PageInfo
                      .self
                  ]
                }

                /// When paginating forwards, are there more items?
                var hasNextPage: Bool { __data["hasNextPage"] }
                /// When paginating forwards, the cursor to continue.
                var endCursor: String? { __data["endCursor"] }
              }

              /// Object.AsMovePackage.Module.Friends.Node
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
                    PaginateMoveModuleListsQuery.Data.Object.AsMovePackage.Module.Friends.Node.self
                  ]
                }

                /// The module's unqualified name.
                var name: String { __data["name"] }
                /// The package that this module was defined in.
                var package: Package? { __data["package"] }

                /// Object.AsMovePackage.Module.Friends.Node.Package
                ///
                /// Parent Type: `MovePackage`
                nonisolated struct Package: SuiGraphQL.SelectionSet {
                  let __data: DataDict
                  init(_dataDict: DataDict) { __data = _dataDict }

                  static var __parentType: any ApolloAPI.ParentType {
                    SuiGraphQL.Objects.MovePackage
                  }
                  static var __selections: [ApolloAPI.Selection] {
                    [
                      .field("__typename", String.self),
                      .field("address", SuiGraphQL.SuiAddress.self),
                    ]
                  }
                  static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
                    [
                      PaginateMoveModuleListsQuery.Data.Object.AsMovePackage.Module.Friends.Node
                        .Package.self
                    ]
                  }

                  /// The MovePackage's ID.
                  var address: SuiGraphQL.SuiAddress { __data["address"] }
                }
              }
            }

            /// Object.AsMovePackage.Module.Structs
            ///
            /// Parent Type: `MoveStructConnection`
            nonisolated struct Structs: SuiGraphQL.SelectionSet {
              let __data: DataDict
              init(_dataDict: DataDict) { __data = _dataDict }

              static var __parentType: any ApolloAPI.ParentType {
                SuiGraphQL.Objects.MoveStructConnection
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
                  PaginateMoveModuleListsQuery.Data.Object.AsMovePackage.Module.Structs.self
                ]
              }

              /// Information to aid in pagination.
              var pageInfo: PageInfo { __data["pageInfo"] }
              /// A list of nodes.
              var nodes: [Node] { __data["nodes"] }

              /// Object.AsMovePackage.Module.Structs.PageInfo
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
                    PaginateMoveModuleListsQuery.Data.Object.AsMovePackage.Module.Structs.PageInfo
                      .self
                  ]
                }

                /// When paginating forwards, are there more items?
                var hasNextPage: Bool { __data["hasNextPage"] }
                /// When paginating forwards, the cursor to continue.
                var endCursor: String? { __data["endCursor"] }
              }

              /// Object.AsMovePackage.Module.Structs.Node
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
                    PaginateMoveModuleListsQuery.Data.Object.AsMovePackage.Module.Structs.Node.self,
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

            /// Object.AsMovePackage.Module.Enums
            ///
            /// Parent Type: `MoveEnumConnection`
            nonisolated struct Enums: SuiGraphQL.SelectionSet {
              let __data: DataDict
              init(_dataDict: DataDict) { __data = _dataDict }

              static var __parentType: any ApolloAPI.ParentType {
                SuiGraphQL.Objects.MoveEnumConnection
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
                  PaginateMoveModuleListsQuery.Data.Object.AsMovePackage.Module.Enums.self
                ]
              }

              /// Information to aid in pagination.
              var pageInfo: PageInfo { __data["pageInfo"] }
              /// A list of nodes.
              var nodes: [Node] { __data["nodes"] }

              /// Object.AsMovePackage.Module.Enums.PageInfo
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
                    PaginateMoveModuleListsQuery.Data.Object.AsMovePackage.Module.Enums.PageInfo
                      .self
                  ]
                }

                /// When paginating forwards, are there more items?
                var hasNextPage: Bool { __data["hasNextPage"] }
                /// When paginating forwards, the cursor to continue.
                var endCursor: String? { __data["endCursor"] }
              }

              /// Object.AsMovePackage.Module.Enums.Node
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
                    PaginateMoveModuleListsQuery.Data.Object.AsMovePackage.Module.Enums.Node.self,
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

            /// Object.AsMovePackage.Module.Functions
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
                  PaginateMoveModuleListsQuery.Data.Object.AsMovePackage.Module.Functions.self
                ]
              }

              /// Information to aid in pagination.
              var pageInfo: PageInfo { __data["pageInfo"] }
              /// A list of nodes.
              var nodes: [Node] { __data["nodes"] }

              /// Object.AsMovePackage.Module.Functions.PageInfo
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
                    PaginateMoveModuleListsQuery.Data.Object.AsMovePackage.Module.Functions.PageInfo
                      .self
                  ]
                }

                /// When paginating forwards, are there more items?
                var hasNextPage: Bool { __data["hasNextPage"] }
                /// When paginating forwards, the cursor to continue.
                var endCursor: String? { __data["endCursor"] }
              }

              /// Object.AsMovePackage.Module.Functions.Node
              ///
              /// Parent Type: `MoveFunction`
              nonisolated struct Node: SuiGraphQL.SelectionSet {
                let __data: DataDict
                init(_dataDict: DataDict) { __data = _dataDict }

                static var __parentType: any ApolloAPI.ParentType {
                  SuiGraphQL.Objects.MoveFunction
                }
                static var __selections: [ApolloAPI.Selection] {
                  [
                    .field("__typename", String.self),
                    .fragment(RPC_MOVE_FUNCTION_FIELDS.self),
                  ]
                }
                static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
                  [
                    PaginateMoveModuleListsQuery.Data.Object.AsMovePackage.Module.Functions.Node
                      .self,
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

}
