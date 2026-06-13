// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

extension SuiGraphQL {
  nonisolated struct GetDynamicFieldsQuery: GraphQLQuery {
    static let operationName: String = "getDynamicFields"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query getDynamicFields($parentId: SuiAddress!, $first: Int, $cursor: String) { address(address: $parentId) { __typename dynamicFields(first: $first, after: $cursor) { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename name { __typename bcs json type { __typename layout repr } } value { __typename ... on MoveValue { json type { __typename repr } } ... on MoveObject { contents { __typename type { __typename repr } json } address digest version } } } } } }"#
      ))

    public var parentId: SuiAddress
    public var first: GraphQLNullable<Int32>
    public var cursor: GraphQLNullable<String>

    public init(
      parentId: SuiAddress,
      first: GraphQLNullable<Int32>,
      cursor: GraphQLNullable<String>
    ) {
      self.parentId = parentId
      self.first = first
      self.cursor = cursor
    }

    @_spi(Unsafe) public var __variables: Variables? {
      [
        "parentId": parentId,
        "first": first,
        "cursor": cursor,
      ]
    }

    nonisolated struct Data: SuiGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Query }
      static var __selections: [ApolloAPI.Selection] {
        [
          .field("address", Address?.self, arguments: ["address": .variable("parentId")])
        ]
      }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
        [
          GetDynamicFieldsQuery.Data.self
        ]
      }

      /// Look-up an account by its SuiAddress.
      ///
      /// If `rootVersion` is specified, nested dynamic field accesses will be fetched at or before this version. This can be used to fetch a child or descendant object bounded by its root object's version, when its immediate parent is wrapped, or a value in a dynamic object field. For any wrapped or child (object-owned) object, its root object can be defined recursively as:
      ///
      /// - The root object of the object it is wrapped in, if it is wrapped.
      /// - The root object of its owner, if it is owned by another object.
      /// - The object itself, if it is not object-owned or wrapped.
      ///
      /// Specifying a `rootVersion` disables nested queries for paginating owned objects or dynamic fields (these queries are only supported at checkpoint boundaries).
      ///
      /// If `atCheckpoint` is specified, the address will be fetched at the latest version as of this checkpoint. This will fail if the provided checkpoint is after the RPC's latest checkpoint.
      ///
      /// If none of the above are specified, the address is fetched at the checkpoint being viewed.
      ///
      /// If the address is fetched by name and the name does not resolve to an address (e.g. the name does not exist or has expired), `null` is returned.
      var address: Address? { __data["address"] }

      /// Address
      ///
      /// Parent Type: `Address`
      nonisolated struct Address: SuiGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Address }
        static var __selections: [ApolloAPI.Selection] {
          [
            .field("__typename", String.self),
            .field(
              "dynamicFields", DynamicFields?.self,
              arguments: [
                "first": .variable("first"),
                "after": .variable("cursor"),
              ]),
          ]
        }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
          [
            GetDynamicFieldsQuery.Data.Address.self
          ]
        }

        /// Dynamic fields owned by this address.
        ///
        /// The address must correspond to an object (account addresses cannot own dynamic fields), but that object may be wrapped.
        var dynamicFields: DynamicFields? { __data["dynamicFields"] }

        /// Address.DynamicFields
        ///
        /// Parent Type: `DynamicFieldConnection`
        nonisolated struct DynamicFields: SuiGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType {
            SuiGraphQL.Objects.DynamicFieldConnection
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
              GetDynamicFieldsQuery.Data.Address.DynamicFields.self
            ]
          }

          /// Information to aid in pagination.
          var pageInfo: PageInfo { __data["pageInfo"] }
          /// A list of nodes.
          var nodes: [Node] { __data["nodes"] }

          /// Address.DynamicFields.PageInfo
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
                GetDynamicFieldsQuery.Data.Address.DynamicFields.PageInfo.self
              ]
            }

            /// When paginating forwards, are there more items?
            var hasNextPage: Bool { __data["hasNextPage"] }
            /// When paginating forwards, the cursor to continue.
            var endCursor: String? { __data["endCursor"] }
          }

          /// Address.DynamicFields.Node
          ///
          /// Parent Type: `DynamicField`
          nonisolated struct Node: SuiGraphQL.SelectionSet {
            let __data: DataDict
            init(_dataDict: DataDict) { __data = _dataDict }

            static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.DynamicField }
            static var __selections: [ApolloAPI.Selection] {
              [
                .field("__typename", String.self),
                .field("name", Name?.self),
                .field("value", Value?.self),
              ]
            }
            static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
              [
                GetDynamicFieldsQuery.Data.Address.DynamicFields.Node.self
              ]
            }

            /// The dynamic field's name, as a Move value.
            var name: Name? { __data["name"] }
            /// The dynamic field's value, as a Move value for dynamic fields and as a MoveObject for dynamic object fields.
            var value: Value? { __data["value"] }

            /// Address.DynamicFields.Node.Name
            ///
            /// Parent Type: `MoveValue`
            nonisolated struct Name: SuiGraphQL.SelectionSet {
              let __data: DataDict
              init(_dataDict: DataDict) { __data = _dataDict }

              static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.MoveValue }
              static var __selections: [ApolloAPI.Selection] {
                [
                  .field("__typename", String.self),
                  .field("bcs", SuiGraphQL.Base64?.self),
                  .field("json", SuiGraphQL.JSON?.self),
                  .field("type", Type_SelectionSet?.self),
                ]
              }
              static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
                [
                  GetDynamicFieldsQuery.Data.Address.DynamicFields.Node.Name.self
                ]
              }

              /// The BCS representation of this value, Base64-encoded.
              var bcs: SuiGraphQL.Base64? { __data["bcs"] }
              /// Representation of a Move value in JSON, where:
              ///
              /// - Addresses, IDs, and UIDs are represented in canonical form, as JSON strings.
              /// - Bools are represented by JSON boolean literals.
              /// - u8, u16, and u32 are represented as JSON numbers.
              /// - u64, u128, and u256 are represented as JSON strings.
              /// - Balances, Strings, and Urls are represented as JSON strings.
              /// - Vectors of bytes are represented as Base64 blobs, and other vectors are represented by JSON arrays.
              /// - Structs are represented by JSON objects.
              /// - Enums are represented by JSON objects, with a field named `@variant` containing the variant name.
              /// - Empty optional values are represented by `null`.
              var json: SuiGraphQL.JSON? { __data["json"] }
              /// The value's type.
              var type: Type_SelectionSet? { __data["type"] }

              /// Address.DynamicFields.Node.Name.Type_SelectionSet
              ///
              /// Parent Type: `MoveType`
              nonisolated struct Type_SelectionSet: SuiGraphQL.SelectionSet {
                let __data: DataDict
                init(_dataDict: DataDict) { __data = _dataDict }

                static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.MoveType }
                static var __selections: [ApolloAPI.Selection] {
                  [
                    .field("__typename", String.self),
                    .field("layout", SuiGraphQL.MoveTypeLayout?.self),
                    .field("repr", String.self),
                  ]
                }
                static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
                  [
                    GetDynamicFieldsQuery.Data.Address.DynamicFields.Node.Name.Type_SelectionSet
                      .self
                  ]
                }

                /// Structured representation of the "shape" of values that match this type. May return no
                /// layout if the type is invalid.
                var layout: SuiGraphQL.MoveTypeLayout? { __data["layout"] }
                /// Flat representation of the type signature, as a displayable string.
                var repr: String { __data["repr"] }
              }
            }

            /// Address.DynamicFields.Node.Value
            ///
            /// Parent Type: `DynamicFieldValue`
            nonisolated struct Value: SuiGraphQL.SelectionSet {
              let __data: DataDict
              init(_dataDict: DataDict) { __data = _dataDict }

              static var __parentType: any ApolloAPI.ParentType {
                SuiGraphQL.Unions.DynamicFieldValue
              }
              static var __selections: [ApolloAPI.Selection] {
                [
                  .field("__typename", String.self),
                  .inlineFragment(AsMoveValue.self),
                  .inlineFragment(AsMoveObject.self),
                ]
              }
              static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
                [
                  GetDynamicFieldsQuery.Data.Address.DynamicFields.Node.Value.self
                ]
              }

              var asMoveValue: AsMoveValue? { _asInlineFragment() }
              var asMoveObject: AsMoveObject? { _asInlineFragment() }

              /// Address.DynamicFields.Node.Value.AsMoveValue
              ///
              /// Parent Type: `MoveValue`
              nonisolated struct AsMoveValue: SuiGraphQL.InlineFragment {
                let __data: DataDict
                init(_dataDict: DataDict) { __data = _dataDict }

                typealias RootEntityType = GetDynamicFieldsQuery.Data.Address.DynamicFields.Node
                  .Value
                static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.MoveValue }
                static var __selections: [ApolloAPI.Selection] {
                  [
                    .field("json", SuiGraphQL.JSON?.self),
                    .field("type", Type_SelectionSet?.self),
                  ]
                }
                static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
                  [
                    GetDynamicFieldsQuery.Data.Address.DynamicFields.Node.Value.self,
                    GetDynamicFieldsQuery.Data.Address.DynamicFields.Node.Value.AsMoveValue.self,
                  ]
                }

                /// Representation of a Move value in JSON, where:
                ///
                /// - Addresses, IDs, and UIDs are represented in canonical form, as JSON strings.
                /// - Bools are represented by JSON boolean literals.
                /// - u8, u16, and u32 are represented as JSON numbers.
                /// - u64, u128, and u256 are represented as JSON strings.
                /// - Balances, Strings, and Urls are represented as JSON strings.
                /// - Vectors of bytes are represented as Base64 blobs, and other vectors are represented by JSON arrays.
                /// - Structs are represented by JSON objects.
                /// - Enums are represented by JSON objects, with a field named `@variant` containing the variant name.
                /// - Empty optional values are represented by `null`.
                var json: SuiGraphQL.JSON? { __data["json"] }
                /// The value's type.
                var type: Type_SelectionSet? { __data["type"] }

                /// Address.DynamicFields.Node.Value.AsMoveValue.Type_SelectionSet
                ///
                /// Parent Type: `MoveType`
                nonisolated struct Type_SelectionSet: SuiGraphQL.SelectionSet {
                  let __data: DataDict
                  init(_dataDict: DataDict) { __data = _dataDict }

                  static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.MoveType }
                  static var __selections: [ApolloAPI.Selection] {
                    [
                      .field("__typename", String.self),
                      .field("repr", String.self),
                    ]
                  }
                  static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
                    [
                      GetDynamicFieldsQuery.Data.Address.DynamicFields.Node.Value.AsMoveValue
                        .Type_SelectionSet.self
                    ]
                  }

                  /// Flat representation of the type signature, as a displayable string.
                  var repr: String { __data["repr"] }
                }
              }

              /// Address.DynamicFields.Node.Value.AsMoveObject
              ///
              /// Parent Type: `MoveObject`
              nonisolated struct AsMoveObject: SuiGraphQL.InlineFragment {
                let __data: DataDict
                init(_dataDict: DataDict) { __data = _dataDict }

                typealias RootEntityType = GetDynamicFieldsQuery.Data.Address.DynamicFields.Node
                  .Value
                static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.MoveObject }
                static var __selections: [ApolloAPI.Selection] {
                  [
                    .field("contents", Contents?.self),
                    .field("address", SuiGraphQL.SuiAddress.self),
                    .field("digest", String?.self),
                    .field("version", SuiGraphQL.UInt53?.self),
                  ]
                }
                static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
                  [
                    GetDynamicFieldsQuery.Data.Address.DynamicFields.Node.Value.self,
                    GetDynamicFieldsQuery.Data.Address.DynamicFields.Node.Value.AsMoveObject.self,
                  ]
                }

                /// The structured representation of the object's contents.
                var contents: Contents? { __data["contents"] }
                /// The MoveObject's ID.
                var address: SuiGraphQL.SuiAddress { __data["address"] }
                /// 32-byte hash that identifies the object's contents, encoded in Base58.
                var digest: String? { __data["digest"] }
                /// The version of this object that this content comes from.
                var version: SuiGraphQL.UInt53? { __data["version"] }

                /// Address.DynamicFields.Node.Value.AsMoveObject.Contents
                ///
                /// Parent Type: `MoveValue`
                nonisolated struct Contents: SuiGraphQL.SelectionSet {
                  let __data: DataDict
                  init(_dataDict: DataDict) { __data = _dataDict }

                  static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.MoveValue }
                  static var __selections: [ApolloAPI.Selection] {
                    [
                      .field("__typename", String.self),
                      .field("type", Type_SelectionSet?.self),
                      .field("json", SuiGraphQL.JSON?.self),
                    ]
                  }
                  static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
                    [
                      GetDynamicFieldsQuery.Data.Address.DynamicFields.Node.Value.AsMoveObject
                        .Contents.self
                    ]
                  }

                  /// The value's type.
                  var type: Type_SelectionSet? { __data["type"] }
                  /// Representation of a Move value in JSON, where:
                  ///
                  /// - Addresses, IDs, and UIDs are represented in canonical form, as JSON strings.
                  /// - Bools are represented by JSON boolean literals.
                  /// - u8, u16, and u32 are represented as JSON numbers.
                  /// - u64, u128, and u256 are represented as JSON strings.
                  /// - Balances, Strings, and Urls are represented as JSON strings.
                  /// - Vectors of bytes are represented as Base64 blobs, and other vectors are represented by JSON arrays.
                  /// - Structs are represented by JSON objects.
                  /// - Enums are represented by JSON objects, with a field named `@variant` containing the variant name.
                  /// - Empty optional values are represented by `null`.
                  var json: SuiGraphQL.JSON? { __data["json"] }

                  /// Address.DynamicFields.Node.Value.AsMoveObject.Contents.Type_SelectionSet
                  ///
                  /// Parent Type: `MoveType`
                  nonisolated struct Type_SelectionSet: SuiGraphQL.SelectionSet {
                    let __data: DataDict
                    init(_dataDict: DataDict) { __data = _dataDict }

                    static var __parentType: any ApolloAPI.ParentType {
                      SuiGraphQL.Objects.MoveType
                    }
                    static var __selections: [ApolloAPI.Selection] {
                      [
                        .field("__typename", String.self),
                        .field("repr", String.self),
                      ]
                    }
                    static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
                      [
                        GetDynamicFieldsQuery.Data.Address.DynamicFields.Node.Value.AsMoveObject
                          .Contents.Type_SelectionSet.self
                      ]
                    }

                    /// Flat representation of the type signature, as a displayable string.
                    var repr: String { __data["repr"] }
                  }
                }
              }
            }
          }
        }
      }
    }
  }

}
