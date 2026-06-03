// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

nonisolated protocol SuiGraphQL_SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == SuiGraphQL.SchemaMetadata {}

nonisolated protocol SuiGraphQL_InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == SuiGraphQL.SchemaMetadata {}

nonisolated protocol SuiGraphQL_MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == SuiGraphQL.SchemaMetadata {}

nonisolated protocol SuiGraphQL_MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI
    .InlineFragment
where Schema == SuiGraphQL.SchemaMetadata {}

extension SuiGraphQL {
  typealias SelectionSet = SuiGraphQL_SelectionSet

  typealias InlineFragment = SuiGraphQL_InlineFragment

  typealias MutableSelectionSet = SuiGraphQL_MutableSelectionSet

  typealias MutableInlineFragment = SuiGraphQL_MutableInlineFragment

  nonisolated enum SchemaMetadata: ApolloAPI.SchemaMetadata {
    static let configuration: any ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self

    private static let objectTypeMap: [String: ApolloAPI.Object] = [
      "Address": SuiGraphQL.Objects.Address,
      "AddressOwner": SuiGraphQL.Objects.AddressOwner,
      "Balance": SuiGraphQL.Objects.Balance,
      "BalanceChange": SuiGraphQL.Objects.BalanceChange,
      "BalanceChangeConnection": SuiGraphQL.Objects.BalanceChangeConnection,
      "BalanceConnection": SuiGraphQL.Objects.BalanceConnection,
      "Checkpoint": SuiGraphQL.Objects.Checkpoint,
      "CheckpointConnection": SuiGraphQL.Objects.CheckpointConnection,
      "CoinMetadata": SuiGraphQL.Objects.CoinMetadata,
      "CommandOutput": SuiGraphQL.Objects.CommandOutput,
      "CommandResult": SuiGraphQL.Objects.CommandResult,
      "ConsensusAddressOwner": SuiGraphQL.Objects.ConsensusAddressOwner,
      "Display": SuiGraphQL.Objects.Display,
      "DynamicField": SuiGraphQL.Objects.DynamicField,
      "DynamicFieldConnection": SuiGraphQL.Objects.DynamicFieldConnection,
      "Epoch": SuiGraphQL.Objects.Epoch,
      "Event": SuiGraphQL.Objects.Event,
      "EventConnection": SuiGraphQL.Objects.EventConnection,
      "ExecutionError": SuiGraphQL.Objects.ExecutionError,
      "ExecutionResult": SuiGraphQL.Objects.ExecutionResult,
      "FeatureFlag": SuiGraphQL.Objects.FeatureFlag,
      "GasCoin": SuiGraphQL.Objects.GasCoin,
      "GasCostSummary": SuiGraphQL.Objects.GasCostSummary,
      "GasEffects": SuiGraphQL.Objects.GasEffects,
      "Immutable": SuiGraphQL.Objects.Immutable,
      "Input": SuiGraphQL.Objects.Input,
      "MoveDatatype": SuiGraphQL.Objects.MoveDatatype,
      "MoveDatatypeTypeParameter": SuiGraphQL.Objects.MoveDatatypeTypeParameter,
      "MoveEnum": SuiGraphQL.Objects.MoveEnum,
      "MoveEnumConnection": SuiGraphQL.Objects.MoveEnumConnection,
      "MoveEnumVariant": SuiGraphQL.Objects.MoveEnumVariant,
      "MoveField": SuiGraphQL.Objects.MoveField,
      "MoveFunction": SuiGraphQL.Objects.MoveFunction,
      "MoveFunctionConnection": SuiGraphQL.Objects.MoveFunctionConnection,
      "MoveFunctionTypeParameter": SuiGraphQL.Objects.MoveFunctionTypeParameter,
      "MoveModule": SuiGraphQL.Objects.MoveModule,
      "MoveModuleConnection": SuiGraphQL.Objects.MoveModuleConnection,
      "MoveObject": SuiGraphQL.Objects.MoveObject,
      "MoveObjectConnection": SuiGraphQL.Objects.MoveObjectConnection,
      "MovePackage": SuiGraphQL.Objects.MovePackage,
      "MoveStruct": SuiGraphQL.Objects.MoveStruct,
      "MoveStructConnection": SuiGraphQL.Objects.MoveStructConnection,
      "MoveType": SuiGraphQL.Objects.MoveType,
      "MoveValue": SuiGraphQL.Objects.MoveValue,
      "Mutation": SuiGraphQL.Objects.Mutation,
      "NameRecord": SuiGraphQL.Objects.NameRecord,
      "Object": SuiGraphQL.Objects.Object,
      "ObjectChange": SuiGraphQL.Objects.ObjectChange,
      "ObjectChangeConnection": SuiGraphQL.Objects.ObjectChangeConnection,
      "ObjectOwner": SuiGraphQL.Objects.ObjectOwner,
      "OpenMoveType": SuiGraphQL.Objects.OpenMoveType,
      "PageInfo": SuiGraphQL.Objects.PageInfo,
      "ProtocolConfig": SuiGraphQL.Objects.ProtocolConfig,
      "ProtocolConfigs": SuiGraphQL.Objects.ProtocolConfigs,
      "Query": SuiGraphQL.Objects.Query,
      "Shared": SuiGraphQL.Objects.Shared,
      "SimulationResult": SuiGraphQL.Objects.SimulationResult,
      "Transaction": SuiGraphQL.Objects.Transaction,
      "TransactionConnection": SuiGraphQL.Objects.TransactionConnection,
      "TransactionEffects": SuiGraphQL.Objects.TransactionEffects,
      "TxResult": SuiGraphQL.Objects.TxResult,
      "UserSignature": SuiGraphQL.Objects.UserSignature,
      "ValidatorAggregatedSignature": SuiGraphQL.Objects.ValidatorAggregatedSignature,
      "ValidatorSet": SuiGraphQL.Objects.ValidatorSet,
    ]

    static func objectType(forTypename typename: String) -> ApolloAPI.Object? {
      objectTypeMap[typename]
    }
  }

  nonisolated enum Objects {}
  nonisolated enum Interfaces {}
  nonisolated enum Unions {}

}
