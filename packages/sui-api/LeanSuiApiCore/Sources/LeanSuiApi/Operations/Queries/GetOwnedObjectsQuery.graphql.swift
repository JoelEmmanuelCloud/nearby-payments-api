// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

extension SuiGraphQL {
  nonisolated struct GetOwnedObjectsQuery: GraphQLQuery {
    static let operationName: String = "getOwnedObjects"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query getOwnedObjects($owner: SuiAddress!, $limit: Int, $cursor: String, $showBcs: Boolean = false, $showContent: Boolean = false, $showDisplay: Boolean = false, $showType: Boolean = false, $showOwner: Boolean = false, $showPreviousTransaction: Boolean = false, $showStorageRebate: Boolean = false, $filter: ObjectFilter) { address(address: $owner) { __typename objects(first: $limit, after: $cursor, filter: $filter) { __typename pageInfo { __typename hasNextPage endCursor } nodes { __typename ...RPC_MOVE_OBJECT_FIELDS } } } }"#,
        fragments: [RPC_MOVE_OBJECT_FIELDS.self, RPC_OBJECT_OWNER_FIELDS.self]
      ))

    public var owner: SuiAddress
    public var limit: GraphQLNullable<Int32>
    public var cursor: GraphQLNullable<String>
    public var showBcs: GraphQLNullable<Bool>
    public var showContent: GraphQLNullable<Bool>
    public var showDisplay: GraphQLNullable<Bool>
    public var showType: GraphQLNullable<Bool>
    public var showOwner: GraphQLNullable<Bool>
    public var showPreviousTransaction: GraphQLNullable<Bool>
    public var showStorageRebate: GraphQLNullable<Bool>
    public var filter: GraphQLNullable<ObjectFilter>

    public init(
      owner: SuiAddress,
      limit: GraphQLNullable<Int32>,
      cursor: GraphQLNullable<String>,
      showBcs: GraphQLNullable<Bool> = false,
      showContent: GraphQLNullable<Bool> = false,
      showDisplay: GraphQLNullable<Bool> = false,
      showType: GraphQLNullable<Bool> = false,
      showOwner: GraphQLNullable<Bool> = false,
      showPreviousTransaction: GraphQLNullable<Bool> = false,
      showStorageRebate: GraphQLNullable<Bool> = false,
      filter: GraphQLNullable<ObjectFilter>
    ) {
      self.owner = owner
      self.limit = limit
      self.cursor = cursor
      self.showBcs = showBcs
      self.showContent = showContent
      self.showDisplay = showDisplay
      self.showType = showType
      self.showOwner = showOwner
      self.showPreviousTransaction = showPreviousTransaction
      self.showStorageRebate = showStorageRebate
      self.filter = filter
    }

    @_spi(Unsafe) public var __variables: Variables? {
      [
        "owner": owner,
        "limit": limit,
        "cursor": cursor,
        "showBcs": showBcs,
        "showContent": showContent,
        "showDisplay": showDisplay,
        "showType": showType,
        "showOwner": showOwner,
        "showPreviousTransaction": showPreviousTransaction,
        "showStorageRebate": showStorageRebate,
        "filter": filter,
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
          GetOwnedObjectsQuery.Data.self
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
              "objects", Objects?.self,
              arguments: [
                "first": .variable("limit"),
                "after": .variable("cursor"),
                "filter": .variable("filter"),
              ]),
          ]
        }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
          [
            GetOwnedObjectsQuery.Data.Address.self
          ]
        }

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
              GetOwnedObjectsQuery.Data.Address.Objects.self
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
                GetOwnedObjectsQuery.Data.Address.Objects.PageInfo.self
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
                .fragment(RPC_MOVE_OBJECT_FIELDS.self),
              ]
            }
            static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
              [
                GetOwnedObjectsQuery.Data.Address.Objects.Node.self,
                RPC_MOVE_OBJECT_FIELDS.self,
              ]
            }

            /// The MoveObject's ID.
            var objectId: SuiGraphQL.SuiAddress { __data["objectId"] }
            /// The structured representation of the object's contents.
            var contents: Contents? { __data["contents"] }
            /// Whether this object can be transfered using the `TransferObjects` Programmable Transaction Command or `sui::transfer::public_transfer`.
            ///
            /// Both these operations require the object to have both the `key` and `store` abilities.
            var hasPublicTransfer: Bool? { __data["hasPublicTransfer"] }
            /// The object's owner kind.
            var owner: Owner? { __data["owner"] }
            /// The transaction that created this version of the object.
            var previousTransaction: PreviousTransaction? { __data["previousTransaction"] }
            /// The SUI returned to the sponsor or sender of the transaction that modifies or deletes this object.
            var storageRebate: SuiGraphQL.BigInt? { __data["storageRebate"] }
            /// 32-byte hash that identifies the object's contents, encoded in Base58.
            var digest: String? { __data["digest"] }
            /// The version of this object that this content comes from.
            var version: SuiGraphQL.UInt53? { __data["version"] }

            struct Fragments: FragmentContainer {
              let __data: DataDict
              init(_dataDict: DataDict) { __data = _dataDict }

              var rPC_MOVE_OBJECT_FIELDS: RPC_MOVE_OBJECT_FIELDS { _toFragment() }
            }

            typealias Contents = RPC_MOVE_OBJECT_FIELDS.Contents

            typealias Owner = RPC_MOVE_OBJECT_FIELDS.Owner

            typealias PreviousTransaction = RPC_MOVE_OBJECT_FIELDS.PreviousTransaction
          }
        }
      }
    }
  }

}
