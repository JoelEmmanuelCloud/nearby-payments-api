// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

extension SuiGraphQL {
  nonisolated struct RPC_MOVE_OBJECT_FIELDS: SuiGraphQL.SelectionSet, Fragment {
    static var fragmentDefinition: StaticString {
      #"fragment RPC_MOVE_OBJECT_FIELDS on MoveObject { __typename objectId: address contents @include(if: $showType) { __typename type { __typename repr } } hasPublicTransfer @include(if: $showContent) contents @include(if: $showContent) { __typename json type { __typename repr layout signature } display @include(if: $showDisplay) { __typename output errors } } hasPublicTransfer @include(if: $showBcs) contents @include(if: $showBcs) { __typename bcs type { __typename repr } } owner @include(if: $showOwner) { __typename ...RPC_OBJECT_OWNER_FIELDS } previousTransaction @include(if: $showPreviousTransaction) { __typename digest } storageRebate @include(if: $showStorageRebate) digest version }"#
    }

    let __data: DataDict
    init(_dataDict: DataDict) { __data = _dataDict }

    static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.MoveObject }
    static var __selections: [ApolloAPI.Selection] {
      [
        .field("__typename", String.self),
        .field("address", alias: "objectId", SuiGraphQL.SuiAddress.self),
        .field("digest", String?.self),
        .field("version", SuiGraphQL.UInt53?.self),
        .include(if: "showType" || "showContent" || "showBcs", .field("contents", Contents?.self)),
        .include(if: "showContent" || "showBcs", .field("hasPublicTransfer", Bool?.self)),
        .include(if: "showOwner", .field("owner", Owner?.self)),
        .include(
          if: "showPreviousTransaction", .field("previousTransaction", PreviousTransaction?.self)),
        .include(if: "showStorageRebate", .field("storageRebate", SuiGraphQL.BigInt?.self)),
      ]
    }
    static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
      [
        RPC_MOVE_OBJECT_FIELDS.self
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

    /// Contents
    ///
    /// Parent Type: `MoveValue`
    nonisolated struct Contents: SuiGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.MoveValue }
      static var __selections: [ApolloAPI.Selection] {
        [
          .field("__typename", String.self),
          .include(if: "showType", .inlineFragment(IfShowType.self)),
          .include(if: "showContent", .inlineFragment(IfShowContent.self)),
          .include(if: "showBcs", .inlineFragment(IfShowBcs.self)),
        ]
      }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
        [
          RPC_MOVE_OBJECT_FIELDS.Contents.self
        ]
      }

      var ifShowType: IfShowType? { _asInlineFragment() }
      var ifShowContent: IfShowContent? { _asInlineFragment() }
      var ifShowBcs: IfShowBcs? { _asInlineFragment() }

      /// Contents.IfShowType
      ///
      /// Parent Type: `MoveValue`
      nonisolated struct IfShowType: SuiGraphQL.InlineFragment {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        typealias RootEntityType = RPC_MOVE_OBJECT_FIELDS.Contents
        static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.MoveValue }
        static var __selections: [ApolloAPI.Selection] {
          [
            .field("type", Type_SelectionSet?.self)
          ]
        }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
          [
            RPC_MOVE_OBJECT_FIELDS.Contents.self,
            RPC_MOVE_OBJECT_FIELDS.Contents.IfShowType.self,
          ]
        }

        /// The value's type.
        var type: Type_SelectionSet? { __data["type"] }

        /// Contents.IfShowType.Type_SelectionSet
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
              RPC_MOVE_OBJECT_FIELDS.Contents.IfShowType.Type_SelectionSet.self,
              RPC_MOVE_OBJECT_FIELDS.Contents.IfShowContent.Type_SelectionSet.self,
            ]
          }

          /// Flat representation of the type signature, as a displayable string.
          var repr: String { __data["repr"] }
          /// Structured representation of the "shape" of values that match this type. May return no
          /// layout if the type is invalid.
          var layout: SuiGraphQL.MoveTypeLayout? { __data["layout"] }
          /// Structured representation of the type signature.
          var signature: SuiGraphQL.MoveTypeSignature { __data["signature"] }
        }
      }

      /// Contents.IfShowContent
      ///
      /// Parent Type: `MoveValue`
      nonisolated struct IfShowContent: SuiGraphQL.InlineFragment {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        typealias RootEntityType = RPC_MOVE_OBJECT_FIELDS.Contents
        static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.MoveValue }
        static var __selections: [ApolloAPI.Selection] {
          [
            .field("json", SuiGraphQL.JSON?.self),
            .field("type", Type_SelectionSet?.self),
            .include(if: "showDisplay", .field("display", Display?.self)),
          ]
        }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
          [
            RPC_MOVE_OBJECT_FIELDS.Contents.self,
            RPC_MOVE_OBJECT_FIELDS.Contents.IfShowContent.self,
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
        /// A rendered JSON blob based on an on-chain template, substituted with data from this value.
        ///
        /// Returns `null` if the value's type does not have an associated `Display` template.
        var display: Display? { __data["display"] }

        /// Contents.IfShowContent.Type_SelectionSet
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
              .field("layout", SuiGraphQL.MoveTypeLayout?.self),
              .field("signature", SuiGraphQL.MoveTypeSignature.self),
            ]
          }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
            [
              RPC_MOVE_OBJECT_FIELDS.Contents.IfShowContent.Type_SelectionSet.self
            ]
          }

          /// Flat representation of the type signature, as a displayable string.
          var repr: String { __data["repr"] }
          /// Structured representation of the "shape" of values that match this type. May return no
          /// layout if the type is invalid.
          var layout: SuiGraphQL.MoveTypeLayout? { __data["layout"] }
          /// Structured representation of the type signature.
          var signature: SuiGraphQL.MoveTypeSignature { __data["signature"] }
        }

        /// Contents.IfShowContent.Display
        ///
        /// Parent Type: `Display`
        nonisolated struct Display: SuiGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Display }
          static var __selections: [ApolloAPI.Selection] {
            [
              .field("__typename", String.self),
              .field("output", SuiGraphQL.JSON?.self),
              .field("errors", SuiGraphQL.JSON?.self),
            ]
          }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
            [
              RPC_MOVE_OBJECT_FIELDS.Contents.IfShowContent.Display.self
            ]
          }

          /// Output for all successfully substituted display fields. Unsuccessful fields will be `null`, and will be accompanied by a field in `errors`, explaining the error.
          var output: SuiGraphQL.JSON? { __data["output"] }
          /// If any fields failed to render, this will contain a mapping from failed field names to error messages. If all fields succeed, this will be `null`.
          var errors: SuiGraphQL.JSON? { __data["errors"] }
        }
      }

      /// Contents.IfShowBcs
      ///
      /// Parent Type: `MoveValue`
      nonisolated struct IfShowBcs: SuiGraphQL.InlineFragment {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        typealias RootEntityType = RPC_MOVE_OBJECT_FIELDS.Contents
        static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.MoveValue }
        static var __selections: [ApolloAPI.Selection] {
          [
            .field("bcs", SuiGraphQL.Base64?.self),
            .field("type", Type_SelectionSet?.self),
          ]
        }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
          [
            RPC_MOVE_OBJECT_FIELDS.Contents.self,
            RPC_MOVE_OBJECT_FIELDS.Contents.IfShowBcs.self,
          ]
        }

        /// The BCS representation of this value, Base64-encoded.
        var bcs: SuiGraphQL.Base64? { __data["bcs"] }
        /// The value's type.
        var type: Type_SelectionSet? { __data["type"] }

        /// Contents.IfShowBcs.Type_SelectionSet
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
              RPC_MOVE_OBJECT_FIELDS.Contents.IfShowBcs.Type_SelectionSet.self,
              RPC_MOVE_OBJECT_FIELDS.Contents.IfShowContent.Type_SelectionSet.self,
            ]
          }

          /// Flat representation of the type signature, as a displayable string.
          var repr: String { __data["repr"] }
          /// Structured representation of the "shape" of values that match this type. May return no
          /// layout if the type is invalid.
          var layout: SuiGraphQL.MoveTypeLayout? { __data["layout"] }
          /// Structured representation of the type signature.
          var signature: SuiGraphQL.MoveTypeSignature { __data["signature"] }
        }
      }
    }

    /// Owner
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
          RPC_MOVE_OBJECT_FIELDS.Owner.self
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

      /// Owner.AsAddressOwner
      ///
      /// Parent Type: `AddressOwner`
      nonisolated struct AsAddressOwner: SuiGraphQL.InlineFragment, ApolloAPI
          .CompositeInlineFragment
      {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        typealias RootEntityType = RPC_MOVE_OBJECT_FIELDS.Owner
        static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.AddressOwner }
        static var __mergedSources: [any ApolloAPI.SelectionSet.Type] {
          [
            RPC_MOVE_OBJECT_FIELDS.Owner.self,
            RPC_OBJECT_OWNER_FIELDS.AsAddressOwner.self,
          ]
        }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
          [
            RPC_MOVE_OBJECT_FIELDS.Owner.self,
            RPC_MOVE_OBJECT_FIELDS.Owner.AsAddressOwner.self,
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

      /// Owner.AsObjectOwner
      ///
      /// Parent Type: `ObjectOwner`
      nonisolated struct AsObjectOwner: SuiGraphQL.InlineFragment, ApolloAPI.CompositeInlineFragment
      {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        typealias RootEntityType = RPC_MOVE_OBJECT_FIELDS.Owner
        static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.ObjectOwner }
        static var __mergedSources: [any ApolloAPI.SelectionSet.Type] {
          [
            RPC_MOVE_OBJECT_FIELDS.Owner.self,
            RPC_OBJECT_OWNER_FIELDS.AsObjectOwner.self,
          ]
        }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
          [
            RPC_MOVE_OBJECT_FIELDS.Owner.self,
            RPC_MOVE_OBJECT_FIELDS.Owner.AsObjectOwner.self,
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

      /// Owner.AsShared
      ///
      /// Parent Type: `Shared`
      nonisolated struct AsShared: SuiGraphQL.InlineFragment, ApolloAPI.CompositeInlineFragment {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        typealias RootEntityType = RPC_MOVE_OBJECT_FIELDS.Owner
        static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Shared }
        static var __mergedSources: [any ApolloAPI.SelectionSet.Type] {
          [
            RPC_MOVE_OBJECT_FIELDS.Owner.self,
            RPC_OBJECT_OWNER_FIELDS.AsShared.self,
          ]
        }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
          [
            RPC_MOVE_OBJECT_FIELDS.Owner.self,
            RPC_MOVE_OBJECT_FIELDS.Owner.AsShared.self,
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

      /// Owner.AsConsensusAddressOwner
      ///
      /// Parent Type: `ConsensusAddressOwner`
      nonisolated struct AsConsensusAddressOwner: SuiGraphQL.InlineFragment, ApolloAPI
          .CompositeInlineFragment
      {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        typealias RootEntityType = RPC_MOVE_OBJECT_FIELDS.Owner
        static var __parentType: any ApolloAPI.ParentType {
          SuiGraphQL.Objects.ConsensusAddressOwner
        }
        static var __mergedSources: [any ApolloAPI.SelectionSet.Type] {
          [
            RPC_MOVE_OBJECT_FIELDS.Owner.self,
            RPC_OBJECT_OWNER_FIELDS.AsConsensusAddressOwner.self,
          ]
        }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
          [
            RPC_MOVE_OBJECT_FIELDS.Owner.self,
            RPC_MOVE_OBJECT_FIELDS.Owner.AsConsensusAddressOwner.self,
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

    /// PreviousTransaction
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
          RPC_MOVE_OBJECT_FIELDS.PreviousTransaction.self
        ]
      }

      /// A 32-byte hash that uniquely identifies the transaction contents, encoded in Base58.
      var digest: String { __data["digest"] }
    }
  }

}
