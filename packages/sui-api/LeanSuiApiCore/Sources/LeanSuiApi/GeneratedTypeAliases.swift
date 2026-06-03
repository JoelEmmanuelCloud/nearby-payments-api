//
//  GeneratedTypeAliases.swift
//  LeanSuiApi
//
//  Apollo codegen nests all generated types under `extension SuiGraphQL { ... }`
//  (schemaNamespace = SuiGraphQL, kept distinct from the module name so there is
//  no LeanSuiApi.LeanSuiApi double-nesting). These internal aliases bring the
//  generated operation / fragment / input-object / scalar / enum type names to
//  module scope so the hand-written mapping & provider code references them
//  unqualified.
//

// Operations + Fragments
typealias DevInspectTransactionBlockQuery = SuiGraphQL.DevInspectTransactionBlockQuery
typealias DryRunTransactionBlockQuery = SuiGraphQL.DryRunTransactionBlockQuery
typealias ExecuteTransactionBlockMutation = SuiGraphQL.ExecuteTransactionBlockMutation
typealias GetAllBalancesQuery = SuiGraphQL.GetAllBalancesQuery
typealias GetBalanceQuery = SuiGraphQL.GetBalanceQuery
typealias GetChainIdentifierQuery = SuiGraphQL.GetChainIdentifierQuery
typealias GetCheckpointQuery = SuiGraphQL.GetCheckpointQuery
typealias GetCheckpointsQuery = SuiGraphQL.GetCheckpointsQuery
typealias GetCoinMetadataQuery = SuiGraphQL.GetCoinMetadataQuery
typealias GetCoinsQuery = SuiGraphQL.GetCoinsQuery
typealias GetCommitteeInfoQuery = SuiGraphQL.GetCommitteeInfoQuery
typealias GetCurrentEpochQuery = SuiGraphQL.GetCurrentEpochQuery
typealias GetDynamicFieldObjectQuery = SuiGraphQL.GetDynamicFieldObjectQuery
typealias GetDynamicFieldsQuery = SuiGraphQL.GetDynamicFieldsQuery
typealias GetLatestCheckpointSequenceNumberQuery = SuiGraphQL.GetLatestCheckpointSequenceNumberQuery
typealias GetLatestSuiSystemStateQuery = SuiGraphQL.GetLatestSuiSystemStateQuery
typealias GetMoveFunctionArgTypesQuery = SuiGraphQL.GetMoveFunctionArgTypesQuery
typealias GetNormalizedMoveFunctionQuery = SuiGraphQL.GetNormalizedMoveFunctionQuery
typealias GetNormalizedMoveModuleQuery = SuiGraphQL.GetNormalizedMoveModuleQuery
typealias GetNormalizedMoveModulesByPackageQuery = SuiGraphQL.GetNormalizedMoveModulesByPackageQuery
typealias GetNormalizedMoveStructQuery = SuiGraphQL.GetNormalizedMoveStructQuery
typealias GetObjectQuery = SuiGraphQL.GetObjectQuery
typealias GetOwnedObjectsQuery = SuiGraphQL.GetOwnedObjectsQuery
typealias GetProtocolConfigQuery = SuiGraphQL.GetProtocolConfigQuery
typealias GetReferenceGasPriceQuery = SuiGraphQL.GetReferenceGasPriceQuery
typealias GetTotalSupplyQuery = SuiGraphQL.GetTotalSupplyQuery
typealias GetTotalTransactionBlocksQuery = SuiGraphQL.GetTotalTransactionBlocksQuery
typealias GetTransactionBlockQuery = SuiGraphQL.GetTransactionBlockQuery
typealias GetTypeLayoutQuery = SuiGraphQL.GetTypeLayoutQuery
typealias GetValidatorsApyQuery = SuiGraphQL.GetValidatorsApyQuery
typealias MultiGetObjectsQuery = SuiGraphQL.MultiGetObjectsQuery
typealias MultiGetTransactionBlocksQuery = SuiGraphQL.MultiGetTransactionBlocksQuery
typealias PaginateCheckpointTransactionBlocksQuery = SuiGraphQL
  .PaginateCheckpointTransactionBlocksQuery
typealias PaginateMoveModuleListsQuery = SuiGraphQL.PaginateMoveModuleListsQuery
typealias PaginateTransactionBlockListsQuery = SuiGraphQL.PaginateTransactionBlockListsQuery
typealias QueryEventsQuery = SuiGraphQL.QueryEventsQuery
typealias QueryTransactionBlocksQuery = SuiGraphQL.QueryTransactionBlocksQuery
typealias RPC_Checkpoint_Fields = SuiGraphQL.RPC_Checkpoint_Fields
typealias RPC_EVENTS_FIELDS = SuiGraphQL.RPC_EVENTS_FIELDS
typealias RPC_MOVE_ENUM_FIELDS = SuiGraphQL.RPC_MOVE_ENUM_FIELDS
typealias RPC_MOVE_FUNCTION_FIELDS = SuiGraphQL.RPC_MOVE_FUNCTION_FIELDS
typealias RPC_MOVE_MODULE_FIELDS = SuiGraphQL.RPC_MOVE_MODULE_FIELDS
typealias RPC_MOVE_OBJECT_FIELDS = SuiGraphQL.RPC_MOVE_OBJECT_FIELDS
typealias RPC_MOVE_STRUCT_FIELDS = SuiGraphQL.RPC_MOVE_STRUCT_FIELDS
typealias RPC_OBJECT_FIELDS = SuiGraphQL.RPC_OBJECT_FIELDS
typealias RPC_OBJECT_OWNER_FIELDS = SuiGraphQL.RPC_OBJECT_OWNER_FIELDS
typealias RPC_TRANSACTION_FIELDS = SuiGraphQL.RPC_TRANSACTION_FIELDS
typealias ResolveNameServiceAddressQuery = SuiGraphQL.ResolveNameServiceAddressQuery
typealias ResolveNameServiceNamesQuery = SuiGraphQL.ResolveNameServiceNamesQuery
typealias TryGetPastObjectQuery = SuiGraphQL.TryGetPastObjectQuery

// Input objects
typealias DynamicFieldName = SuiGraphQL.DynamicFieldName
typealias EventFilter = SuiGraphQL.EventFilter
typealias ObjectFilter = SuiGraphQL.ObjectFilter
typealias ObjectKey = SuiGraphQL.ObjectKey
typealias TransactionFilter = SuiGraphQL.TransactionFilter

// Custom scalars
typealias Base64 = SuiGraphQL.Base64
typealias BigInt = SuiGraphQL.BigInt
typealias DateTime = SuiGraphQL.DateTime
typealias JSON = SuiGraphQL.JSON
typealias MoveTypeLayout = SuiGraphQL.MoveTypeLayout
typealias MoveTypeSignature = SuiGraphQL.MoveTypeSignature
typealias OpenMoveTypeSignature = SuiGraphQL.OpenMoveTypeSignature
typealias SuiAddress = SuiGraphQL.SuiAddress
typealias UInt53 = SuiGraphQL.UInt53

// Enums
typealias ExecutionStatus = SuiGraphQL.ExecutionStatus
typealias MoveAbility = SuiGraphQL.MoveAbility
typealias MoveVisibility = SuiGraphQL.MoveVisibility
typealias OwnerKind = SuiGraphQL.OwnerKind
typealias TransactionKindInput = SuiGraphQL.TransactionKindInput
