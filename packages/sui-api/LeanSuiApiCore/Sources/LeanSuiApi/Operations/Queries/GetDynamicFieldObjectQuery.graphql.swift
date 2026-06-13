// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

extension SuiGraphQL {
  nonisolated struct GetDynamicFieldObjectQuery: GraphQLQuery {
    static let operationName: String = "getDynamicFieldObject"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query getDynamicFieldObject($parentId: SuiAddress!, $name: DynamicFieldName!) { address(address: $parentId) { __typename dynamicObjectField(name: $name) { __typename value { __typename ... on MoveObject { owner { __typename ... on ObjectOwner { address { __typename asObject { __typename address digest version storageRebate owner { __typename ... on ObjectOwner { address { __typename address } } } previousTransaction { __typename digest } asMoveObject { __typename contents { __typename json type { __typename repr layout } } hasPublicTransfer } } } } } } } } } }"#
      ))

    public var parentId: SuiAddress
    public var name: DynamicFieldName

    public init(
      parentId: SuiAddress,
      name: DynamicFieldName
    ) {
      self.parentId = parentId
      self.name = name
    }

    @_spi(Unsafe) public var __variables: Variables? {
      [
        "parentId": parentId,
        "name": name,
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
          GetDynamicFieldObjectQuery.Data.self
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
              "dynamicObjectField", DynamicObjectField?.self, arguments: ["name": .variable("name")]
            ),
          ]
        }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
          [
            GetDynamicFieldObjectQuery.Data.Address.self
          ]
        }

        /// Access a dynamic object field on an object using its type and BCS-encoded name.
        ///
        /// Returns `null` if a dynamic object field with that name could not be found attached to the object with this address.
        var dynamicObjectField: DynamicObjectField? { __data["dynamicObjectField"] }

        /// Address.DynamicObjectField
        ///
        /// Parent Type: `DynamicField`
        nonisolated struct DynamicObjectField: SuiGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.DynamicField }
          static var __selections: [ApolloAPI.Selection] {
            [
              .field("__typename", String.self),
              .field("value", Value?.self),
            ]
          }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
            [
              GetDynamicFieldObjectQuery.Data.Address.DynamicObjectField.self
            ]
          }

          /// The dynamic field's value, as a Move value for dynamic fields and as a MoveObject for dynamic object fields.
          var value: Value? { __data["value"] }

          /// Address.DynamicObjectField.Value
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
                .inlineFragment(AsMoveObject.self),
              ]
            }
            static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
              [
                GetDynamicFieldObjectQuery.Data.Address.DynamicObjectField.Value.self
              ]
            }

            var asMoveObject: AsMoveObject? { _asInlineFragment() }

            /// Address.DynamicObjectField.Value.AsMoveObject
            ///
            /// Parent Type: `MoveObject`
            nonisolated struct AsMoveObject: SuiGraphQL.InlineFragment {
              let __data: DataDict
              init(_dataDict: DataDict) { __data = _dataDict }

              typealias RootEntityType = GetDynamicFieldObjectQuery.Data.Address.DynamicObjectField
                .Value
              static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.MoveObject }
              static var __selections: [ApolloAPI.Selection] {
                [
                  .field("owner", Owner?.self)
                ]
              }
              static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
                [
                  GetDynamicFieldObjectQuery.Data.Address.DynamicObjectField.Value.self,
                  GetDynamicFieldObjectQuery.Data.Address.DynamicObjectField.Value.AsMoveObject
                    .self,
                ]
              }

              /// The object's owner kind.
              var owner: Owner? { __data["owner"] }

              /// Address.DynamicObjectField.Value.AsMoveObject.Owner
              ///
              /// Parent Type: `Owner`
              nonisolated struct Owner: SuiGraphQL.SelectionSet {
                let __data: DataDict
                init(_dataDict: DataDict) { __data = _dataDict }

                static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Unions.Owner }
                static var __selections: [ApolloAPI.Selection] {
                  [
                    .field("__typename", String.self),
                    .inlineFragment(AsObjectOwner.self),
                  ]
                }
                static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
                  [
                    GetDynamicFieldObjectQuery.Data.Address.DynamicObjectField.Value.AsMoveObject
                      .Owner.self
                  ]
                }

                var asObjectOwner: AsObjectOwner? { _asInlineFragment() }

                /// Address.DynamicObjectField.Value.AsMoveObject.Owner.AsObjectOwner
                ///
                /// Parent Type: `ObjectOwner`
                nonisolated struct AsObjectOwner: SuiGraphQL.InlineFragment {
                  let __data: DataDict
                  init(_dataDict: DataDict) { __data = _dataDict }

                  typealias RootEntityType = GetDynamicFieldObjectQuery.Data.Address
                    .DynamicObjectField.Value.AsMoveObject.Owner
                  static var __parentType: any ApolloAPI.ParentType {
                    SuiGraphQL.Objects.ObjectOwner
                  }
                  static var __selections: [ApolloAPI.Selection] {
                    [
                      .field("address", Address?.self)
                    ]
                  }
                  static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
                    [
                      GetDynamicFieldObjectQuery.Data.Address.DynamicObjectField.Value.AsMoveObject
                        .Owner.self,
                      GetDynamicFieldObjectQuery.Data.Address.DynamicObjectField.Value.AsMoveObject
                        .Owner.AsObjectOwner.self,
                    ]
                  }

                  /// The owner's address.
                  var address: Address? { __data["address"] }

                  /// Address.DynamicObjectField.Value.AsMoveObject.Owner.AsObjectOwner.Address
                  ///
                  /// Parent Type: `Address`
                  nonisolated struct Address: SuiGraphQL.SelectionSet {
                    let __data: DataDict
                    init(_dataDict: DataDict) { __data = _dataDict }

                    static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Address }
                    static var __selections: [ApolloAPI.Selection] {
                      [
                        .field("__typename", String.self),
                        .field("asObject", AsObject?.self),
                      ]
                    }
                    static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
                      [
                        GetDynamicFieldObjectQuery.Data.Address.DynamicObjectField.Value
                          .AsMoveObject.Owner.AsObjectOwner.Address.self
                      ]
                    }

                    /// Attempts to fetch the object at this address.
                    var asObject: AsObject? { __data["asObject"] }

                    /// Address.DynamicObjectField.Value.AsMoveObject.Owner.AsObjectOwner.Address.AsObject
                    ///
                    /// Parent Type: `Object`
                    nonisolated struct AsObject: SuiGraphQL.SelectionSet {
                      let __data: DataDict
                      init(_dataDict: DataDict) { __data = _dataDict }

                      static var __parentType: any ApolloAPI.ParentType {
                        SuiGraphQL.Objects.Object
                      }
                      static var __selections: [ApolloAPI.Selection] {
                        [
                          .field("__typename", String.self),
                          .field("address", SuiGraphQL.SuiAddress.self),
                          .field("digest", String?.self),
                          .field("version", SuiGraphQL.UInt53?.self),
                          .field("storageRebate", SuiGraphQL.BigInt?.self),
                          .field("owner", Owner?.self),
                          .field("previousTransaction", PreviousTransaction?.self),
                          .field("asMoveObject", AsMoveObject?.self),
                        ]
                      }
                      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
                        [
                          GetDynamicFieldObjectQuery.Data.Address.DynamicObjectField.Value
                            .AsMoveObject.Owner.AsObjectOwner.Address.AsObject.self
                        ]
                      }

                      /// The Object's ID.
                      var address: SuiGraphQL.SuiAddress { __data["address"] }
                      /// 32-byte hash that identifies the object's contents, encoded in Base58.
                      var digest: String? { __data["digest"] }
                      /// The version of this object that this content comes from.
                      var version: SuiGraphQL.UInt53? { __data["version"] }
                      /// The SUI returned to the sponsor or sender of the transaction that modifies or deletes this object.
                      var storageRebate: SuiGraphQL.BigInt? { __data["storageRebate"] }
                      /// The object's owner kind.
                      var owner: Owner? { __data["owner"] }
                      /// The transaction that created this version of the object.
                      var previousTransaction: PreviousTransaction? {
                        __data["previousTransaction"]
                      }
                      /// Attempts to convert the object into a MoveObject.
                      var asMoveObject: AsMoveObject? { __data["asMoveObject"] }

                      /// Address.DynamicObjectField.Value.AsMoveObject.Owner.AsObjectOwner.Address.AsObject.Owner
                      ///
                      /// Parent Type: `Owner`
                      nonisolated struct Owner: SuiGraphQL.SelectionSet {
                        let __data: DataDict
                        init(_dataDict: DataDict) { __data = _dataDict }

                        static var __parentType: any ApolloAPI.ParentType {
                          SuiGraphQL.Unions.Owner
                        }
                        static var __selections: [ApolloAPI.Selection] {
                          [
                            .field("__typename", String.self),
                            .inlineFragment(AsObjectOwner.self),
                          ]
                        }
                        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
                          [
                            GetDynamicFieldObjectQuery.Data.Address.DynamicObjectField.Value
                              .AsMoveObject.Owner.AsObjectOwner.Address.AsObject.Owner.self
                          ]
                        }

                        var asObjectOwner: AsObjectOwner? { _asInlineFragment() }

                        /// Address.DynamicObjectField.Value.AsMoveObject.Owner.AsObjectOwner.Address.AsObject.Owner.AsObjectOwner
                        ///
                        /// Parent Type: `ObjectOwner`
                        nonisolated struct AsObjectOwner: SuiGraphQL.InlineFragment {
                          let __data: DataDict
                          init(_dataDict: DataDict) { __data = _dataDict }

                          typealias RootEntityType = GetDynamicFieldObjectQuery.Data.Address
                            .DynamicObjectField.Value.AsMoveObject.Owner.AsObjectOwner.Address
                            .AsObject.Owner
                          static var __parentType: any ApolloAPI.ParentType {
                            SuiGraphQL.Objects.ObjectOwner
                          }
                          static var __selections: [ApolloAPI.Selection] {
                            [
                              .field("address", Address?.self)
                            ]
                          }
                          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
                            [
                              GetDynamicFieldObjectQuery.Data.Address.DynamicObjectField.Value
                                .AsMoveObject.Owner.AsObjectOwner.Address.AsObject.Owner.self,
                              GetDynamicFieldObjectQuery.Data.Address.DynamicObjectField.Value
                                .AsMoveObject.Owner.AsObjectOwner.Address.AsObject.Owner
                                .AsObjectOwner.self,
                            ]
                          }

                          /// The owner's address.
                          var address: Address? { __data["address"] }

                          /// Address.DynamicObjectField.Value.AsMoveObject.Owner.AsObjectOwner.Address.AsObject.Owner.AsObjectOwner.Address
                          ///
                          /// Parent Type: `Address`
                          nonisolated struct Address: SuiGraphQL.SelectionSet {
                            let __data: DataDict
                            init(_dataDict: DataDict) { __data = _dataDict }

                            static var __parentType: any ApolloAPI.ParentType {
                              SuiGraphQL.Objects.Address
                            }
                            static var __selections: [ApolloAPI.Selection] {
                              [
                                .field("__typename", String.self),
                                .field("address", SuiGraphQL.SuiAddress.self),
                              ]
                            }
                            static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
                              [
                                GetDynamicFieldObjectQuery.Data.Address.DynamicObjectField.Value
                                  .AsMoveObject.Owner.AsObjectOwner.Address.AsObject.Owner
                                  .AsObjectOwner.Address.self
                              ]
                            }

                            /// The Address' identifier, a 32-byte number represented as a 64-character hex string, with a lead "0x".
                            var address: SuiGraphQL.SuiAddress { __data["address"] }
                          }
                        }
                      }

                      /// Address.DynamicObjectField.Value.AsMoveObject.Owner.AsObjectOwner.Address.AsObject.PreviousTransaction
                      ///
                      /// Parent Type: `Transaction`
                      nonisolated struct PreviousTransaction: SuiGraphQL.SelectionSet {
                        let __data: DataDict
                        init(_dataDict: DataDict) { __data = _dataDict }

                        static var __parentType: any ApolloAPI.ParentType {
                          SuiGraphQL.Objects.Transaction
                        }
                        static var __selections: [ApolloAPI.Selection] {
                          [
                            .field("__typename", String.self),
                            .field("digest", String.self),
                          ]
                        }
                        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
                          [
                            GetDynamicFieldObjectQuery.Data.Address.DynamicObjectField.Value
                              .AsMoveObject.Owner.AsObjectOwner.Address.AsObject.PreviousTransaction
                              .self
                          ]
                        }

                        /// A 32-byte hash that uniquely identifies the transaction contents, encoded in Base58.
                        var digest: String { __data["digest"] }
                      }

                      /// Address.DynamicObjectField.Value.AsMoveObject.Owner.AsObjectOwner.Address.AsObject.AsMoveObject
                      ///
                      /// Parent Type: `MoveObject`
                      nonisolated struct AsMoveObject: SuiGraphQL.SelectionSet {
                        let __data: DataDict
                        init(_dataDict: DataDict) { __data = _dataDict }

                        static var __parentType: any ApolloAPI.ParentType {
                          SuiGraphQL.Objects.MoveObject
                        }
                        static var __selections: [ApolloAPI.Selection] {
                          [
                            .field("__typename", String.self),
                            .field("contents", Contents?.self),
                            .field("hasPublicTransfer", Bool?.self),
                          ]
                        }
                        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
                          [
                            GetDynamicFieldObjectQuery.Data.Address.DynamicObjectField.Value
                              .AsMoveObject.Owner.AsObjectOwner.Address.AsObject.AsMoveObject.self
                          ]
                        }

                        /// The structured representation of the object's contents.
                        var contents: Contents? { __data["contents"] }
                        /// Whether this object can be transfered using the `TransferObjects` Programmable Transaction Command or `sui::transfer::public_transfer`.
                        ///
                        /// Both these operations require the object to have both the `key` and `store` abilities.
                        var hasPublicTransfer: Bool? { __data["hasPublicTransfer"] }

                        /// Address.DynamicObjectField.Value.AsMoveObject.Owner.AsObjectOwner.Address.AsObject.AsMoveObject.Contents
                        ///
                        /// Parent Type: `MoveValue`
                        nonisolated struct Contents: SuiGraphQL.SelectionSet {
                          let __data: DataDict
                          init(_dataDict: DataDict) { __data = _dataDict }

                          static var __parentType: any ApolloAPI.ParentType {
                            SuiGraphQL.Objects.MoveValue
                          }
                          static var __selections: [ApolloAPI.Selection] {
                            [
                              .field("__typename", String.self),
                              .field("json", SuiGraphQL.JSON?.self),
                              .field("type", Type_SelectionSet?.self),
                            ]
                          }
                          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
                            [
                              GetDynamicFieldObjectQuery.Data.Address.DynamicObjectField.Value
                                .AsMoveObject.Owner.AsObjectOwner.Address.AsObject.AsMoveObject
                                .Contents.self
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

                          /// Address.DynamicObjectField.Value.AsMoveObject.Owner.AsObjectOwner.Address.AsObject.AsMoveObject.Contents.Type_SelectionSet
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
                                .field("layout", SuiGraphQL.MoveTypeLayout?.self),
                              ]
                            }
                            static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
                              [
                                GetDynamicFieldObjectQuery.Data.Address.DynamicObjectField.Value
                                  .AsMoveObject.Owner.AsObjectOwner.Address.AsObject.AsMoveObject
                                  .Contents.Type_SelectionSet.self
                              ]
                            }

                            /// Flat representation of the type signature, as a displayable string.
                            var repr: String { __data["repr"] }
                            /// Structured representation of the "shape" of values that match this type. May return no
                            /// layout if the type is invalid.
                            var layout: SuiGraphQL.MoveTypeLayout? { __data["layout"] }
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
      }
    }
  }

}
