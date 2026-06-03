// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

extension SuiGraphQL {
  nonisolated struct MultiGetObjectsQuery: GraphQLQuery {
    static let operationName: String = "multiGetObjects"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query multiGetObjects($keys: [ObjectKey!]!, $showBcs: Boolean = false, $showContent: Boolean = false, $showDisplay: Boolean = false, $showType: Boolean = false, $showOwner: Boolean = false, $showPreviousTransaction: Boolean = false, $showStorageRebate: Boolean = false) { multiGetObjects(keys: $keys) { __typename ...RPC_OBJECT_FIELDS } }"#,
        fragments: [RPC_OBJECT_FIELDS.self, RPC_OBJECT_OWNER_FIELDS.self]
      ))

    public var keys: [ObjectKey]
    public var showBcs: GraphQLNullable<Bool>
    public var showContent: GraphQLNullable<Bool>
    public var showDisplay: GraphQLNullable<Bool>
    public var showType: GraphQLNullable<Bool>
    public var showOwner: GraphQLNullable<Bool>
    public var showPreviousTransaction: GraphQLNullable<Bool>
    public var showStorageRebate: GraphQLNullable<Bool>

    public init(
      keys: [ObjectKey],
      showBcs: GraphQLNullable<Bool> = false,
      showContent: GraphQLNullable<Bool> = false,
      showDisplay: GraphQLNullable<Bool> = false,
      showType: GraphQLNullable<Bool> = false,
      showOwner: GraphQLNullable<Bool> = false,
      showPreviousTransaction: GraphQLNullable<Bool> = false,
      showStorageRebate: GraphQLNullable<Bool> = false
    ) {
      self.keys = keys
      self.showBcs = showBcs
      self.showContent = showContent
      self.showDisplay = showDisplay
      self.showType = showType
      self.showOwner = showOwner
      self.showPreviousTransaction = showPreviousTransaction
      self.showStorageRebate = showStorageRebate
    }

    @_spi(Unsafe) public var __variables: Variables? {
      [
        "keys": keys,
        "showBcs": showBcs,
        "showContent": showContent,
        "showDisplay": showDisplay,
        "showType": showType,
        "showOwner": showOwner,
        "showPreviousTransaction": showPreviousTransaction,
        "showStorageRebate": showStorageRebate,
      ]
    }

    nonisolated struct Data: SuiGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Query }
      static var __selections: [ApolloAPI.Selection] {
        [
          .field("multiGetObjects", [MultiGetObject?].self, arguments: ["keys": .variable("keys")])
        ]
      }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
        [
          MultiGetObjectsQuery.Data.self
        ]
      }

      /// Fetch objects by their keys.
      ///
      /// Returns a list of objects that is guaranteed to be the same length as `keys`. If an object in `keys` could not be found in the store, its corresponding entry in the result will be `null`. This could be because the object never existed, or because it was pruned.
      var multiGetObjects: [MultiGetObject?] { __data["multiGetObjects"] }

      /// MultiGetObject
      ///
      /// Parent Type: `Object`
      nonisolated struct MultiGetObject: SuiGraphQL.SelectionSet {
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
            MultiGetObjectsQuery.Data.MultiGetObject.self,
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
