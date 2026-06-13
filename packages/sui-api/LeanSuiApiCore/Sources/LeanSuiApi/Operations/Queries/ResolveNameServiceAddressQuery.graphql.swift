// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

extension SuiGraphQL {
  nonisolated struct ResolveNameServiceAddressQuery: GraphQLQuery {
    static let operationName: String = "resolveNameServiceAddress"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query resolveNameServiceAddress($domain: String!) { address(name: $domain) { __typename address } }"#
      ))

    public var domain: String

    public init(domain: String) {
      self.domain = domain
    }

    @_spi(Unsafe) public var __variables: Variables? { ["domain": domain] }

    nonisolated struct Data: SuiGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Query }
      static var __selections: [ApolloAPI.Selection] {
        [
          .field("address", Address?.self, arguments: ["name": .variable("domain")])
        ]
      }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
        [
          ResolveNameServiceAddressQuery.Data.self
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
          ]
        }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
          [
            ResolveNameServiceAddressQuery.Data.Address.self
          ]
        }

        /// The Address' identifier, a 32-byte number represented as a 64-character hex string, with a lead "0x".
        var address: SuiGraphQL.SuiAddress { __data["address"] }
      }
    }
  }

}
