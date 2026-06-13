// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

extension SuiGraphQL {
  nonisolated struct TryGetPastObjectQuery: GraphQLQuery {
    static let operationName: String = "tryGetPastObject"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query tryGetPastObject($id: SuiAddress!, $version: UInt53, $showBcs: Boolean = false, $showOwner: Boolean = false, $showPreviousTransaction: Boolean = false, $showContent: Boolean = false, $showDisplay: Boolean = false, $showType: Boolean = false, $showStorageRebate: Boolean = false) { current: object(address: $id) { __typename address version } object(address: $id, version: $version) { __typename ...RPC_OBJECT_FIELDS } }"#,
        fragments: [RPC_OBJECT_FIELDS.self, RPC_OBJECT_OWNER_FIELDS.self]
      ))

    public var id: SuiAddress
    public var version: GraphQLNullable<UInt53>
    public var showBcs: GraphQLNullable<Bool>
    public var showOwner: GraphQLNullable<Bool>
    public var showPreviousTransaction: GraphQLNullable<Bool>
    public var showContent: GraphQLNullable<Bool>
    public var showDisplay: GraphQLNullable<Bool>
    public var showType: GraphQLNullable<Bool>
    public var showStorageRebate: GraphQLNullable<Bool>

    public init(
      id: SuiAddress,
      version: GraphQLNullable<UInt53>,
      showBcs: GraphQLNullable<Bool> = false,
      showOwner: GraphQLNullable<Bool> = false,
      showPreviousTransaction: GraphQLNullable<Bool> = false,
      showContent: GraphQLNullable<Bool> = false,
      showDisplay: GraphQLNullable<Bool> = false,
      showType: GraphQLNullable<Bool> = false,
      showStorageRebate: GraphQLNullable<Bool> = false
    ) {
      self.id = id
      self.version = version
      self.showBcs = showBcs
      self.showOwner = showOwner
      self.showPreviousTransaction = showPreviousTransaction
      self.showContent = showContent
      self.showDisplay = showDisplay
      self.showType = showType
      self.showStorageRebate = showStorageRebate
    }

    @_spi(Unsafe) public var __variables: Variables? {
      [
        "id": id,
        "version": version,
        "showBcs": showBcs,
        "showOwner": showOwner,
        "showPreviousTransaction": showPreviousTransaction,
        "showContent": showContent,
        "showDisplay": showDisplay,
        "showType": showType,
        "showStorageRebate": showStorageRebate,
      ]
    }

    nonisolated struct Data: SuiGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Query }
      static var __selections: [ApolloAPI.Selection] {
        [
          .field(
            "object", alias: "current", Current?.self, arguments: ["address": .variable("id")]),
          .field(
            "object", Object?.self,
            arguments: [
              "address": .variable("id"),
              "version": .variable("version"),
            ]),
        ]
      }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
        [
          TryGetPastObjectQuery.Data.self
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
      var current: Current? { __data["current"] }
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

      /// Current
      ///
      /// Parent Type: `Object`
      nonisolated struct Current: SuiGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Object }
        static var __selections: [ApolloAPI.Selection] {
          [
            .field("__typename", String.self),
            .field("address", SuiGraphQL.SuiAddress.self),
            .field("version", SuiGraphQL.UInt53?.self),
          ]
        }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
          [
            TryGetPastObjectQuery.Data.Current.self
          ]
        }

        /// The Object's ID.
        var address: SuiGraphQL.SuiAddress { __data["address"] }
        /// The version of this object that this content comes from.
        var version: SuiGraphQL.UInt53? { __data["version"] }
      }

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
            .fragment(RPC_OBJECT_FIELDS.self),
          ]
        }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
          [
            TryGetPastObjectQuery.Data.Object.self,
            RPC_OBJECT_FIELDS.self,
          ]
        }

        /// The Object's ID.
        var objectId: SuiGraphQL.SuiAddress { __data["objectId"] }
        /// The version of this object that this content comes from.
        var version: SuiGraphQL.UInt53? { __data["version"] }
        /// Attempts to convert the object into a MoveObject.
        var asMoveObject: AsMoveObject? { __data["asMoveObject"] }
        /// The object's owner kind.
        var owner: Owner? { __data["owner"] }
        /// The transaction that created this version of the object.
        var previousTransaction: PreviousTransaction? { __data["previousTransaction"] }
        /// The SUI returned to the sponsor or sender of the transaction that modifies or deletes this object.
        var storageRebate: SuiGraphQL.BigInt? { __data["storageRebate"] }
        /// 32-byte hash that identifies the object's contents, encoded in Base58.
        var digest: String? { __data["digest"] }

        struct Fragments: FragmentContainer {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          var rPC_OBJECT_FIELDS: RPC_OBJECT_FIELDS { _toFragment() }
        }

        typealias AsMoveObject = RPC_OBJECT_FIELDS.AsMoveObject

        typealias Owner = RPC_OBJECT_FIELDS.Owner

        typealias PreviousTransaction = RPC_OBJECT_FIELDS.PreviousTransaction
      }
    }
  }

}
