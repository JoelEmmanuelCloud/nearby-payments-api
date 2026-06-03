// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

extension SuiGraphQL {
  nonisolated struct RPC_EVENTS_FIELDS: SuiGraphQL.SelectionSet, Fragment {
    static var fragmentDefinition: StaticString {
      #"fragment RPC_EVENTS_FIELDS on Event { __typename transactionModule { __typename package { __typename address } name } sender { __typename address } contents { __typename type { __typename repr } json bcs } timestamp }"#
    }

    let __data: DataDict
    init(_dataDict: DataDict) { __data = _dataDict }

    static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Event }
    static var __selections: [ApolloAPI.Selection] {
      [
        .field("__typename", String.self),
        .field("transactionModule", TransactionModule?.self),
        .field("sender", Sender?.self),
        .field("contents", Contents?.self),
        .field("timestamp", SuiGraphQL.DateTime?.self),
      ]
    }
    static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
      [
        RPC_EVENTS_FIELDS.self
      ]
    }

    /// The module containing the function that was called in the programmable transaction, that resulted in this event being emitted.
    var transactionModule: TransactionModule? { __data["transactionModule"] }
    /// Address of the sender of the transaction that emitted this event.
    var sender: Sender? { __data["sender"] }
    /// The Move value emitted for this event.
    var contents: Contents? { __data["contents"] }
    /// Timestamp corresponding to the checkpoint this event's transaction was finalized in.
    /// All events from the same transaction share the same timestamp.
    ///
    /// `null` for simulated/executed transactions as they are not included in a checkpoint.
    var timestamp: SuiGraphQL.DateTime? { __data["timestamp"] }

    /// TransactionModule
    ///
    /// Parent Type: `MoveModule`
    nonisolated struct TransactionModule: SuiGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.MoveModule }
      static var __selections: [ApolloAPI.Selection] {
        [
          .field("__typename", String.self),
          .field("package", Package?.self),
          .field("name", String.self),
        ]
      }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
        [
          RPC_EVENTS_FIELDS.TransactionModule.self
        ]
      }

      /// The package that this module was defined in.
      var package: Package? { __data["package"] }
      /// The module's unqualified name.
      var name: String { __data["name"] }

      /// TransactionModule.Package
      ///
      /// Parent Type: `MovePackage`
      nonisolated struct Package: SuiGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.MovePackage }
        static var __selections: [ApolloAPI.Selection] {
          [
            .field("__typename", String.self),
            .field("address", SuiGraphQL.SuiAddress.self),
          ]
        }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
          [
            RPC_EVENTS_FIELDS.TransactionModule.Package.self
          ]
        }

        /// The MovePackage's ID.
        var address: SuiGraphQL.SuiAddress { __data["address"] }
      }
    }

    /// Sender
    ///
    /// Parent Type: `Address`
    nonisolated struct Sender: SuiGraphQL.SelectionSet {
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
          RPC_EVENTS_FIELDS.Sender.self
        ]
      }

      /// The Address' identifier, a 32-byte number represented as a 64-character hex string, with a lead "0x".
      var address: SuiGraphQL.SuiAddress { __data["address"] }
    }

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
          .field("type", Type_SelectionSet?.self),
          .field("json", SuiGraphQL.JSON?.self),
          .field("bcs", SuiGraphQL.Base64?.self),
        ]
      }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
        [
          RPC_EVENTS_FIELDS.Contents.self
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
      /// The BCS representation of this value, Base64-encoded.
      var bcs: SuiGraphQL.Base64? { __data["bcs"] }

      /// Contents.Type_SelectionSet
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
            RPC_EVENTS_FIELDS.Contents.Type_SelectionSet.self
          ]
        }

        /// Flat representation of the type signature, as a displayable string.
        var repr: String { __data["repr"] }
      }
    }
  }

}
