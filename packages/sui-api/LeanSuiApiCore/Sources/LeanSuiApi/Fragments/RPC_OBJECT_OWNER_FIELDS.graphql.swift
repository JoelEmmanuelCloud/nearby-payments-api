// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

extension SuiGraphQL {
  nonisolated struct RPC_OBJECT_OWNER_FIELDS: SuiGraphQL.SelectionSet, Fragment {
    static var fragmentDefinition: StaticString {
      #"fragment RPC_OBJECT_OWNER_FIELDS on Owner { __typename ... on AddressOwner { address { __typename address } } ... on ObjectOwner { address { __typename address } } ... on Shared { initialSharedVersion } ... on Immutable { __typename } ... on ConsensusAddressOwner { address { __typename address } } }"#
    }

    let __data: DataDict
    init(_dataDict: DataDict) { __data = _dataDict }

    static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Unions.Owner }
    static var __selections: [ApolloAPI.Selection] {
      [
        .field("__typename", String.self),
        .inlineFragment(AsAddressOwner.self),
        .inlineFragment(AsObjectOwner.self),
        .inlineFragment(AsShared.self),
        .inlineFragment(AsImmutable.self),
        .inlineFragment(AsConsensusAddressOwner.self),
      ]
    }
    static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
      [
        RPC_OBJECT_OWNER_FIELDS.self
      ]
    }

    var asAddressOwner: AsAddressOwner? { _asInlineFragment() }
    var asObjectOwner: AsObjectOwner? { _asInlineFragment() }
    var asShared: AsShared? { _asInlineFragment() }
    var asImmutable: AsImmutable? { _asInlineFragment() }
    var asConsensusAddressOwner: AsConsensusAddressOwner? { _asInlineFragment() }

    /// AsAddressOwner
    ///
    /// Parent Type: `AddressOwner`
    nonisolated struct AsAddressOwner: SuiGraphQL.InlineFragment {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      typealias RootEntityType = RPC_OBJECT_OWNER_FIELDS
      static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.AddressOwner }
      static var __selections: [ApolloAPI.Selection] {
        [
          .field("address", Address?.self)
        ]
      }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
        [
          RPC_OBJECT_OWNER_FIELDS.self,
          RPC_OBJECT_OWNER_FIELDS.AsAddressOwner.self,
        ]
      }

      /// The owner's address.
      var address: Address? { __data["address"] }

      /// AsAddressOwner.Address
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
          ]
        }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
          [
            RPC_OBJECT_OWNER_FIELDS.AsAddressOwner.Address.self
          ]
        }

        /// The Address' identifier, a 32-byte number represented as a 64-character hex string, with a lead "0x".
        var address: SuiGraphQL.SuiAddress { __data["address"] }
      }
    }

    /// AsObjectOwner
    ///
    /// Parent Type: `ObjectOwner`
    nonisolated struct AsObjectOwner: SuiGraphQL.InlineFragment {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      typealias RootEntityType = RPC_OBJECT_OWNER_FIELDS
      static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.ObjectOwner }
      static var __selections: [ApolloAPI.Selection] {
        [
          .field("address", Address?.self)
        ]
      }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
        [
          RPC_OBJECT_OWNER_FIELDS.self,
          RPC_OBJECT_OWNER_FIELDS.AsObjectOwner.self,
        ]
      }

      /// The owner's address.
      var address: Address? { __data["address"] }

      /// AsObjectOwner.Address
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
          ]
        }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
          [
            RPC_OBJECT_OWNER_FIELDS.AsObjectOwner.Address.self
          ]
        }

        /// The Address' identifier, a 32-byte number represented as a 64-character hex string, with a lead "0x".
        var address: SuiGraphQL.SuiAddress { __data["address"] }
      }
    }

    /// AsShared
    ///
    /// Parent Type: `Shared`
    nonisolated struct AsShared: SuiGraphQL.InlineFragment {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      typealias RootEntityType = RPC_OBJECT_OWNER_FIELDS
      static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Shared }
      static var __selections: [ApolloAPI.Selection] {
        [
          .field("initialSharedVersion", SuiGraphQL.UInt53?.self)
        ]
      }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
        [
          RPC_OBJECT_OWNER_FIELDS.self,
          RPC_OBJECT_OWNER_FIELDS.AsShared.self,
        ]
      }

      /// The version at which the object became shared.
      var initialSharedVersion: SuiGraphQL.UInt53? { __data["initialSharedVersion"] }
    }

    /// AsImmutable
    ///
    /// Parent Type: `Immutable`
    nonisolated struct AsImmutable: SuiGraphQL.InlineFragment {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      typealias RootEntityType = RPC_OBJECT_OWNER_FIELDS
      static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Immutable }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
        [
          RPC_OBJECT_OWNER_FIELDS.self,
          RPC_OBJECT_OWNER_FIELDS.AsImmutable.self,
        ]
      }
    }

    /// AsConsensusAddressOwner
    ///
    /// Parent Type: `ConsensusAddressOwner`
    nonisolated struct AsConsensusAddressOwner: SuiGraphQL.InlineFragment {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      typealias RootEntityType = RPC_OBJECT_OWNER_FIELDS
      static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.ConsensusAddressOwner }
      static var __selections: [ApolloAPI.Selection] {
        [
          .field("address", Address?.self)
        ]
      }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
        [
          RPC_OBJECT_OWNER_FIELDS.self,
          RPC_OBJECT_OWNER_FIELDS.AsConsensusAddressOwner.self,
        ]
      }

      /// The owner's address.
      var address: Address? { __data["address"] }

      /// AsConsensusAddressOwner.Address
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
          ]
        }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
          [
            RPC_OBJECT_OWNER_FIELDS.AsConsensusAddressOwner.Address.self
          ]
        }

        /// The Address' identifier, a 32-byte number represented as a 64-character hex string, with a lead "0x".
        var address: SuiGraphQL.SuiAddress { __data["address"] }
      }
    }
  }

}
