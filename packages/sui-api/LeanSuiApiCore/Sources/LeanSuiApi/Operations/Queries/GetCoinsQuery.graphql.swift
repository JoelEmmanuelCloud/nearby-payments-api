// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

extension SuiGraphQL {
  nonisolated struct GetCoinsQuery: GraphQLQuery {
    static let operationName: String = "getCoins"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query getCoins($owner: SuiAddress!, $first: Int, $cursor: String, $type: String = "0x2::coin::Coin<0x2::sui::SUI>") { address(address: $owner) { __typename address objects(first: $first, after: $cursor, filter: { type: $type }) { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename owner { __typename ...RPC_OBJECT_OWNER_FIELDS } contents { __typename bcs json type { __typename repr } } address version digest previousTransaction { __typename digest } } } } }"#,
        fragments: [RPC_OBJECT_OWNER_FIELDS.self]
      ))

    public var owner: SuiAddress
    public var first: GraphQLNullable<Int32>
    public var cursor: GraphQLNullable<String>
    public var type: GraphQLNullable<String>

    public init(
      owner: SuiAddress,
      first: GraphQLNullable<Int32>,
      cursor: GraphQLNullable<String>,
      type: GraphQLNullable<String> = "0x2::coin::Coin<0x2::sui::SUI>"
    ) {
      self.owner = owner
      self.first = first
      self.cursor = cursor
      self.type = type
    }

    @_spi(Unsafe) public var __variables: Variables? {
      [
        "owner": owner,
        "first": first,
        "cursor": cursor,
        "type": type,
      ]
    }

    nonisolated struct Data: SuiGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Query }
      static var __selections: [ApolloAPI.Selection] {
        [
          .field("address", Address?.self, arguments: ["address": .variable("owner")])
        ]
      }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
        [
          GetCoinsQuery.Data.self
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
            .field("address", SuiGraphQL.SuiAddress.self),
            .field(
              "objects", Objects?.self,
              arguments: [
                "first": .variable("first"),
                "after": .variable("cursor"),
                "filter": ["type": .variable("type")],
              ]),
          ]
        }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
          [
            GetCoinsQuery.Data.Address.self
          ]
        }

        /// The Address' identifier, a 32-byte number represented as a 64-character hex string, with a lead "0x".
        var address: SuiGraphQL.SuiAddress { __data["address"] }
        /// Objects owned by this address, optionally filtered by type.
        var objects: Objects? { __data["objects"] }

        /// Address.Objects
        ///
        /// Parent Type: `MoveObjectConnection`
        nonisolated struct Objects: SuiGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType {
            SuiGraphQL.Objects.MoveObjectConnection
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
              GetCoinsQuery.Data.Address.Objects.self
            ]
          }

          /// Information to aid in pagination.
          var pageInfo: PageInfo { __data["pageInfo"] }
          /// A list of nodes.
          var nodes: [Node] { __data["nodes"] }

          /// Address.Objects.PageInfo
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
                GetCoinsQuery.Data.Address.Objects.PageInfo.self
              ]
            }

            /// When paginating forwards, are there more items?
            var hasNextPage: Bool { __data["hasNextPage"] }
            /// When paginating forwards, the cursor to continue.
            var endCursor: String? { __data["endCursor"] }
          }

          /// Address.Objects.Node
          ///
          /// Parent Type: `MoveObject`
          nonisolated struct Node: SuiGraphQL.SelectionSet {
            let __data: DataDict
            init(_dataDict: DataDict) { __data = _dataDict }

            static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.MoveObject }
            static var __selections: [ApolloAPI.Selection] {
              [
                .field("__typename", String.self),
                .field("owner", Owner?.self),
                .field("contents", Contents?.self),
                .field("address", SuiGraphQL.SuiAddress.self),
                .field("version", SuiGraphQL.UInt53?.self),
                .field("digest", String?.self),
                .field("previousTransaction", PreviousTransaction?.self),
              ]
            }
            static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
              [
                GetCoinsQuery.Data.Address.Objects.Node.self
              ]
            }

            /// The object's owner kind.
            var owner: Owner? { __data["owner"] }
            /// The structured representation of the object's contents.
            var contents: Contents? { __data["contents"] }
            /// The MoveObject's ID.
            var address: SuiGraphQL.SuiAddress { __data["address"] }
            /// The version of this object that this content comes from.
            var version: SuiGraphQL.UInt53? { __data["version"] }
            /// 32-byte hash that identifies the object's contents, encoded in Base58.
            var digest: String? { __data["digest"] }
            /// The transaction that created this version of the object.
            var previousTransaction: PreviousTransaction? { __data["previousTransaction"] }

            /// Address.Objects.Node.Owner
            ///
            /// Parent Type: `Owner`
            nonisolated struct Owner: SuiGraphQL.SelectionSet {
              let __data: DataDict
              init(_dataDict: DataDict) { __data = _dataDict }

              static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Unions.Owner }
              static var __selections: [ApolloAPI.Selection] {
                [
                  .field("__typename", String.self),
                  .fragment(RPC_OBJECT_OWNER_FIELDS.self),
                ]
              }
              static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
                [
                  GetCoinsQuery.Data.Address.Objects.Node.Owner.self
                ]
              }

              var asAddressOwner: AsAddressOwner? { _asInlineFragment() }
              var asObjectOwner: AsObjectOwner? { _asInlineFragment() }
              var asShared: AsShared? { _asInlineFragment() }
              var asConsensusAddressOwner: AsConsensusAddressOwner? { _asInlineFragment() }

              struct Fragments: FragmentContainer {
                let __data: DataDict
                init(_dataDict: DataDict) { __data = _dataDict }

                var rPC_OBJECT_OWNER_FIELDS: RPC_OBJECT_OWNER_FIELDS { _toFragment() }
              }

              /// Address.Objects.Node.Owner.AsAddressOwner
              ///
              /// Parent Type: `AddressOwner`
              nonisolated struct AsAddressOwner: SuiGraphQL.InlineFragment, ApolloAPI
                  .CompositeInlineFragment
              {
                let __data: DataDict
                init(_dataDict: DataDict) { __data = _dataDict }

                typealias RootEntityType = GetCoinsQuery.Data.Address.Objects.Node.Owner
                static var __parentType: any ApolloAPI.ParentType {
                  SuiGraphQL.Objects.AddressOwner
                }
                static var __mergedSources: [any ApolloAPI.SelectionSet.Type] {
                  [
                    GetCoinsQuery.Data.Address.Objects.Node.Owner.self,
                    RPC_OBJECT_OWNER_FIELDS.AsAddressOwner.self,
                  ]
                }
                static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
                  [
                    GetCoinsQuery.Data.Address.Objects.Node.Owner.self,
                    GetCoinsQuery.Data.Address.Objects.Node.Owner.AsAddressOwner.self,
                    RPC_OBJECT_OWNER_FIELDS.self,
                    RPC_OBJECT_OWNER_FIELDS.AsAddressOwner.self,
                  ]
                }

                /// The owner's address.
                var address: Address? { __data["address"] }

                struct Fragments: FragmentContainer {
                  let __data: DataDict
                  init(_dataDict: DataDict) { __data = _dataDict }

                  var rPC_OBJECT_OWNER_FIELDS: RPC_OBJECT_OWNER_FIELDS { _toFragment() }
                }

                typealias Address = RPC_OBJECT_OWNER_FIELDS.AsAddressOwner.Address
              }

              /// Address.Objects.Node.Owner.AsObjectOwner
              ///
              /// Parent Type: `ObjectOwner`
              nonisolated struct AsObjectOwner: SuiGraphQL.InlineFragment, ApolloAPI
                  .CompositeInlineFragment
              {
                let __data: DataDict
                init(_dataDict: DataDict) { __data = _dataDict }

                typealias RootEntityType = GetCoinsQuery.Data.Address.Objects.Node.Owner
                static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.ObjectOwner }
                static var __mergedSources: [any ApolloAPI.SelectionSet.Type] {
                  [
                    GetCoinsQuery.Data.Address.Objects.Node.Owner.self,
                    RPC_OBJECT_OWNER_FIELDS.AsObjectOwner.self,
                  ]
                }
                static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
                  [
                    GetCoinsQuery.Data.Address.Objects.Node.Owner.self,
                    GetCoinsQuery.Data.Address.Objects.Node.Owner.AsObjectOwner.self,
                    RPC_OBJECT_OWNER_FIELDS.self,
                    RPC_OBJECT_OWNER_FIELDS.AsObjectOwner.self,
                  ]
                }

                /// The owner's address.
                var address: Address? { __data["address"] }

                struct Fragments: FragmentContainer {
                  let __data: DataDict
                  init(_dataDict: DataDict) { __data = _dataDict }

                  var rPC_OBJECT_OWNER_FIELDS: RPC_OBJECT_OWNER_FIELDS { _toFragment() }
                }

                typealias Address = RPC_OBJECT_OWNER_FIELDS.AsObjectOwner.Address
              }

              /// Address.Objects.Node.Owner.AsShared
              ///
              /// Parent Type: `Shared`
              nonisolated struct AsShared: SuiGraphQL.InlineFragment, ApolloAPI
                  .CompositeInlineFragment
              {
                let __data: DataDict
                init(_dataDict: DataDict) { __data = _dataDict }

                typealias RootEntityType = GetCoinsQuery.Data.Address.Objects.Node.Owner
                static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Shared }
                static var __mergedSources: [any ApolloAPI.SelectionSet.Type] {
                  [
                    GetCoinsQuery.Data.Address.Objects.Node.Owner.self,
                    RPC_OBJECT_OWNER_FIELDS.AsShared.self,
                  ]
                }
                static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
                  [
                    GetCoinsQuery.Data.Address.Objects.Node.Owner.self,
                    GetCoinsQuery.Data.Address.Objects.Node.Owner.AsShared.self,
                    RPC_OBJECT_OWNER_FIELDS.self,
                    RPC_OBJECT_OWNER_FIELDS.AsShared.self,
                  ]
                }

                /// The version at which the object became shared.
                var initialSharedVersion: SuiGraphQL.UInt53? { __data["initialSharedVersion"] }

                struct Fragments: FragmentContainer {
                  let __data: DataDict
                  init(_dataDict: DataDict) { __data = _dataDict }

                  var rPC_OBJECT_OWNER_FIELDS: RPC_OBJECT_OWNER_FIELDS { _toFragment() }
                }
              }

              /// Address.Objects.Node.Owner.AsConsensusAddressOwner
              ///
              /// Parent Type: `ConsensusAddressOwner`
              nonisolated struct AsConsensusAddressOwner: SuiGraphQL.InlineFragment, ApolloAPI
                  .CompositeInlineFragment
              {
                let __data: DataDict
                init(_dataDict: DataDict) { __data = _dataDict }

                typealias RootEntityType = GetCoinsQuery.Data.Address.Objects.Node.Owner
                static var __parentType: any ApolloAPI.ParentType {
                  SuiGraphQL.Objects.ConsensusAddressOwner
                }
                static var __mergedSources: [any ApolloAPI.SelectionSet.Type] {
                  [
                    GetCoinsQuery.Data.Address.Objects.Node.Owner.self,
                    RPC_OBJECT_OWNER_FIELDS.AsConsensusAddressOwner.self,
                  ]
                }
                static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
                  [
                    GetCoinsQuery.Data.Address.Objects.Node.Owner.self,
                    GetCoinsQuery.Data.Address.Objects.Node.Owner.AsConsensusAddressOwner.self,
                    RPC_OBJECT_OWNER_FIELDS.self,
                    RPC_OBJECT_OWNER_FIELDS.AsConsensusAddressOwner.self,
                  ]
                }

                /// The owner's address.
                var address: Address? { __data["address"] }

                struct Fragments: FragmentContainer {
                  let __data: DataDict
                  init(_dataDict: DataDict) { __data = _dataDict }

                  var rPC_OBJECT_OWNER_FIELDS: RPC_OBJECT_OWNER_FIELDS { _toFragment() }
                }

                typealias Address = RPC_OBJECT_OWNER_FIELDS.AsConsensusAddressOwner.Address
              }
            }

            /// Address.Objects.Node.Contents
            ///
            /// Parent Type: `MoveValue`
            nonisolated struct Contents: SuiGraphQL.SelectionSet {
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
                  GetCoinsQuery.Data.Address.Objects.Node.Contents.self
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

              /// Address.Objects.Node.Contents.Type_SelectionSet
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
                    GetCoinsQuery.Data.Address.Objects.Node.Contents.Type_SelectionSet.self
                  ]
                }

                /// Flat representation of the type signature, as a displayable string.
                var repr: String { __data["repr"] }
              }
            }

            /// Address.Objects.Node.PreviousTransaction
            ///
            /// Parent Type: `Transaction`
            nonisolated struct PreviousTransaction: SuiGraphQL.SelectionSet {
              let __data: DataDict
              init(_dataDict: DataDict) { __data = _dataDict }

              static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Transaction }
              static var __selections: [ApolloAPI.Selection] {
                [
                  .field("__typename", String.self),
                  .field("digest", String.self),
                ]
              }
              static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
                [
                  GetCoinsQuery.Data.Address.Objects.Node.PreviousTransaction.self
                ]
              }

              /// A 32-byte hash that uniquely identifies the transaction contents, encoded in Base58.
              var digest: String { __data["digest"] }
            }
          }
        }
      }
    }
  }

}
