// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI
@_spi(Execution) @_spi(Unsafe) import ApolloAPI

extension SuiGraphQL {
  nonisolated struct GetProtocolConfigQuery: GraphQLQuery {
    static let operationName: String = "getProtocolConfig"
    static let operationDocument: ApolloAPI.OperationDocument = .init(
      definition: .init(
        #"query getProtocolConfig($protocolVersion: UInt53) { protocolConfigs(version: $protocolVersion) { __typename protocolVersion configs { __typename key value } featureFlags { __typename key value } } }"#
      ))

    public var protocolVersion: GraphQLNullable<UInt53>

    public init(protocolVersion: GraphQLNullable<UInt53>) {
      self.protocolVersion = protocolVersion
    }

    @_spi(Unsafe) public var __variables: Variables? { ["protocolVersion": protocolVersion] }

    nonisolated struct Data: SuiGraphQL.SelectionSet {
      let __data: DataDict
      init(_dataDict: DataDict) { __data = _dataDict }

      static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.Query }
      static var __selections: [ApolloAPI.Selection] {
        [
          .field(
            "protocolConfigs", ProtocolConfigs?.self,
            arguments: ["version": .variable("protocolVersion")])
        ]
      }
      static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
        [
          GetProtocolConfigQuery.Data.self
        ]
      }

      /// Fetch the protocol config by protocol version, or the latest protocol config used on chain if no version is provided.
      var protocolConfigs: ProtocolConfigs? { __data["protocolConfigs"] }

      /// ProtocolConfigs
      ///
      /// Parent Type: `ProtocolConfigs`
      nonisolated struct ProtocolConfigs: SuiGraphQL.SelectionSet {
        let __data: DataDict
        init(_dataDict: DataDict) { __data = _dataDict }

        static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.ProtocolConfigs }
        static var __selections: [ApolloAPI.Selection] {
          [
            .field("__typename", String.self),
            .field("protocolVersion", SuiGraphQL.UInt53.self),
            .field("configs", [Config].self),
            .field("featureFlags", [FeatureFlag].self),
          ]
        }
        static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
          [
            GetProtocolConfigQuery.Data.ProtocolConfigs.self
          ]
        }

        var protocolVersion: SuiGraphQL.UInt53 { __data["protocolVersion"] }
        /// List all available configurations and their values.
        var configs: [Config] { __data["configs"] }
        /// List all available feature flags and their values.
        var featureFlags: [FeatureFlag] { __data["featureFlags"] }

        /// ProtocolConfigs.Config
        ///
        /// Parent Type: `ProtocolConfig`
        nonisolated struct Config: SuiGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.ProtocolConfig }
          static var __selections: [ApolloAPI.Selection] {
            [
              .field("__typename", String.self),
              .field("key", String.self),
              .field("value", String?.self),
            ]
          }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
            [
              GetProtocolConfigQuery.Data.ProtocolConfigs.Config.self
            ]
          }

          /// Configuration name.
          var key: String { __data["key"] }
          /// Configuration value.
          var value: String? { __data["value"] }
        }

        /// ProtocolConfigs.FeatureFlag
        ///
        /// Parent Type: `FeatureFlag`
        nonisolated struct FeatureFlag: SuiGraphQL.SelectionSet {
          let __data: DataDict
          init(_dataDict: DataDict) { __data = _dataDict }

          static var __parentType: any ApolloAPI.ParentType { SuiGraphQL.Objects.FeatureFlag }
          static var __selections: [ApolloAPI.Selection] {
            [
              .field("__typename", String.self),
              .field("key", String.self),
              .field("value", Bool.self),
            ]
          }
          static var __fulfilledFragments: [any ApolloAPI.SelectionSet.Type] {
            [
              GetProtocolConfigQuery.Data.ProtocolConfigs.FeatureFlag.self
            ]
          }

          /// Feature flag name.
          var key: String { __data["key"] }
          /// Feature flag value.
          var value: Bool { __data["value"] }
        }
      }
    }
  }

}
