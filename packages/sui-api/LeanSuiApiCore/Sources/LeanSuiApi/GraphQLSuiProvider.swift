//
//  GraphQLSuiProvider.swift
//  LeanSuiApi
//
//  Lean GraphQL provider. Returns owned domain DTOs; Apollo-generated types
//  never escape this package. Built incrementally, one verified endpoint
//  batch at a time.
//

import Apollo
import ApolloAPI
import Foundation

public struct GraphQLSuiProvider: Sendable {
  internal let apollo: ApolloClient

  /// Create a provider for the given Sui network.
  public init(network: SuiNetwork) {
    self.apollo = ApolloClient(url: network.graphQLEndpoint)
  }

  /// Create a provider against a custom GraphQL endpoint URL.
  init(url: URL) {  // internal: URL not bridgeable; Kotlin uses init(network:)
    self.apollo = ApolloClient(url: url)
  }

  // MARK: - Scalar endpoints

  /// Return the first four bytes of the chain's genesis checkpoint digest.
  public func getChainIdentifier() async throws -> String {
    let result = try await GraphQLClient.fetchQuery(
      client: apollo,
      query: GetChainIdentifierQuery()
    )
    return try require(result.data?.chainIdentifier, "chainIdentifier")
  }

  /// Return the reference gas price for the network (`u64`).
  public func getReferenceGasPrice() async throws -> UInt64 {
    let result = try await GraphQLClient.fetchQuery(
      client: apollo,
      query: GetReferenceGasPriceQuery()
    )
    let raw = try require(result.data?.epoch?.referenceGasPrice, "epoch.referenceGasPrice")
    return try Scalars.uInt64(raw, field: "epoch.referenceGasPrice")
  }

  /// Return the total number of transaction blocks known to the server (`u64`).
  public func getTotalTransactionBlocks() async throws -> UInt64 {
    let result = try await GraphQLClient.fetchQuery(
      client: apollo,
      query: GetTotalTransactionBlocksQuery()
    )
    let raw = try require(
      result.data?.checkpoint?.networkTotalTransactions,
      "checkpoint.networkTotalTransactions"
    )
    return try Scalars.uInt64(raw, field: "checkpoint.networkTotalTransactions")
  }

  /// Return the sequence number of the latest executed checkpoint (`u64`).
  public func getLatestCheckpointSequenceNumber() async throws -> UInt64 {
    let result = try await GraphQLClient.fetchQuery(
      client: apollo,
      query: GetLatestCheckpointSequenceNumberQuery()
    )
    let raw = try require(result.data?.checkpoint?.sequenceNumber, "checkpoint.sequenceNumber")
    return try Scalars.uInt64(raw, field: "checkpoint.sequenceNumber")
  }

  /// Return the total supply of a coin type, in base units (`u64`).
  public func totalSupply(_ coinType: String) async throws -> UInt64 {
    let result = try await GraphQLClient.fetchQuery(
      client: apollo,
      query: GetTotalSupplyQuery(coinType: coinType)
    )
    let raw = try require(result.data?.coinMetadata?.supply, "coinMetadata.supply")
    return try Scalars.uInt64(raw, field: "coinMetadata.supply")
  }

  // MARK: - Coin endpoints

  /// Return metadata (symbol, decimals, …) for a coin type.
  public func getCoinMetadata(coinType: String) async throws -> SuiCoinMetadata {
    let result = try await GraphQLClient.fetchQuery(
      client: apollo,
      query: GetCoinMetadataQuery(coinType: coinType)
    )
    let m = try require(result.data?.coinMetadata, "coinMetadata")
    return SuiCoinMetadata(graphql: m)
  }

  /// Return the balance for one coin type owned by an address.
  public func getBalance(owner: String, coinType: String? = nil) async throws -> CoinBalance {
    let typeArg: GraphQLNullable<String> = coinType.map { .some($0) } ?? .null
    let result = try await GraphQLClient.fetchQuery(
      client: apollo,
      query: GetBalanceQuery(owner: owner, type: typeArg)
    )
    let balance = try require(result.data?.address?.balance, "address.balance")
    return try CoinBalance(graphql: balance)
  }

  /// Return all coin-type balances owned by an address.
  public func getAllBalances(
    owner: String,
    limit: Int? = nil,
    cursor: String? = nil
  ) async throws -> CoinBalancePage {
    let limitArg: GraphQLNullable<Int32> = limit.map { .some(Int32($0)) } ?? .null
    let cursorArg: GraphQLNullable<String> = cursor.map { .some($0) } ?? .null
    let result = try await GraphQLClient.fetchQuery(
      client: apollo,
      query: GetAllBalancesQuery(owner: owner, limit: limitArg, cursor: cursorArg)
    )
    let balances = try require(result.data?.address?.balances, "address.balances")
    return Page(
      data: try balances.nodes.map { try CoinBalance(graphql: $0) },
      pageInfo: PageInfo(graphql: balances.pageInfo)
    )
  }

  /// Return the individual coin objects of a given type owned by an address,
  /// with pagination. Used for gas-coin selection during transaction building.
  public func getCoins(
    owner: String,
    coinType: String = "0x2::coin::Coin<0x2::sui::SUI>",
    limit: Int? = nil,
    cursor: String? = nil
  ) async throws -> CoinStructPage {
    let result = try await GraphQLClient.fetchQuery(
      client: apollo,
      query: GetCoinsQuery(
        owner: owner,
        first: limit.map { .some(Int32($0)) } ?? .null,
        cursor: cursor.map { .some($0) } ?? .null,
        type: .some(coinType)
      )
    )
    guard let objects = result.data?.address?.objects else {
      return Page(data: [], pageInfo: PageInfo())
    }
    return Page(
      data: try objects.nodes.map { try CoinStruct(graphql: $0) },
      pageInfo: PageInfo(graphql: objects.pageInfo)
    )
  }

  // MARK: - Object endpoints

  /// Return the object information for a single object.
  public func getObject(
    objectId: String,
    options: SuiObjectDataOptions = SuiObjectDataOptions()
  ) async throws -> SuiObjectResponse {
    let result = try await GraphQLClient.fetchQuery(
      client: apollo,
      query: GetObjectQuery(
        id: objectId,
        showBcs: .some(options.showBcs),
        showOwner: .some(options.showOwner),
        showPreviousTransaction: .some(options.showPreviousTransaction),
        showContent: .some(options.showContent),
        showDisplay: .some(options.showDisplay),
        showType: .some(options.showType),
        showStorageRebate: .some(options.showStorageRebate)
      )
    )
    guard let object = result.data?.object else {
      return SuiObjectResponse(data: nil, error: "notExists")
    }
    return SuiObjectResponse(
      data: try SuiObjectData(graphql: object.fragments.rPC_OBJECT_FIELDS),
      error: nil
    )
  }

  /// Return the object information for multiple objects.
  public func getMultiObjects(
    ids: [String],
    options: SuiObjectDataOptions = SuiObjectDataOptions()
  ) async throws -> [SuiObjectResponse] {
    let result = try await GraphQLClient.fetchQuery(
      client: apollo,
      query: MultiGetObjectsQuery(
        keys: ids.map { ObjectKey(address: $0) },
        showBcs: .some(options.showBcs),
        showContent: .some(options.showContent),
        showDisplay: .some(options.showDisplay),
        showType: .some(options.showType),
        showOwner: .some(options.showOwner),
        showPreviousTransaction: .some(options.showPreviousTransaction),
        showStorageRebate: .some(options.showStorageRebate)
      )
    )
    let objects = try require(result.data?.multiGetObjects, "multiGetObjects")
    return try objects.map { node in
      guard let node else { return SuiObjectResponse(data: nil, error: "notExists") }
      return SuiObjectResponse(
        data: try SuiObjectData(graphql: node.fragments.rPC_OBJECT_FIELDS),
        error: nil
      )
    }
  }

  /// Return the list of objects owned by an address.
  public func getOwnedObjects(
    owner: String,
    options: SuiObjectDataOptions = SuiObjectDataOptions(),
    limit: Int? = nil,
    cursor: String? = nil
  ) async throws -> SuiObjectResponsePage {
    let result = try await GraphQLClient.fetchQuery(
      client: apollo,
      query: GetOwnedObjectsQuery(
        owner: owner,
        limit: limit.map { .some(Int32($0)) } ?? .null,
        cursor: cursor.map { .some($0) } ?? .null,
        showBcs: .some(options.showBcs),
        showContent: .some(options.showContent),
        showDisplay: .some(options.showDisplay),
        showType: .some(options.showType),
        showOwner: .some(options.showOwner),
        showPreviousTransaction: .some(options.showPreviousTransaction),
        showStorageRebate: .some(options.showStorageRebate),
        filter: .null
      )
    )
    guard let objects = result.data?.address?.objects else {
      return Page(data: [], pageInfo: PageInfo())
    }
    return Page(
      data: try objects.nodes.map {
        SuiObjectResponse(
          data: try SuiObjectData(graphql: $0.fragments.rPC_MOVE_OBJECT_FIELDS),
          error: nil
        )
      },
      pageInfo: PageInfo(graphql: objects.pageInfo)
    )
  }

  // MARK: - Write path (byte-level)

  /// Execute a signed transaction. Byte-level entry point: BCS `TransactionData`
  /// bytes plus serialized signatures.
  public func executeTransactionBlock(
    txBytes: [UInt8],
    signatures: [String],
    options: TransactionResponseOptions = TransactionResponseOptions()
  ) async throws -> SuiTransactionBlockResponse {
    let result = try await GraphQLClient.performMutation(
      client: apollo,
      mutation: ExecuteTransactionBlockMutation(
        transactionDataBcs: Data(txBytes).base64EncodedString(),
        signatures: signatures,
        showBalanceChanges: .some(options.showBalanceChanges),
        showEffects: .some(options.showEffects),
        showRawEffects: false,
        showEvents: .some(options.showEvents),
        showInput: .some(options.showInput),
        showObjectChanges: .some(options.showObjectChanges),
        showRawInput: false
      )
    )
    let exec = try require(result.data?.executeTransaction, "executeTransaction")
    return try SuiTransactionBlockResponse(execute: exec)
  }

  /// Dry-run BCS-serialized `TransactionData` bytes (no signature required).
  public func dryRunTransactionBlock(txBytes: [UInt8]) async throws -> DryRunResult {
    let result = try await GraphQLClient.fetchQuery(
      client: apollo,
      query: DryRunTransactionBlockQuery(
        transaction: JSON(Data(txBytes).base64EncodedString()),
        showBalanceChanges: true,
        showEffects: true,
        showRawEffects: false,
        showEvents: true,
        showObjectChanges: true
      )
    )
    let sim = try require(result.data?.simulateTransaction, "simulateTransaction")
    return try DryRunResult(graphql: sim)
  }

  // MARK: - Write path (builder/signer driven)

  /// Build, sign, and execute a transaction block.
  public func signAndExecuteTransactionBlock(
    transactionBlock: any TransactionBlockProtocol,
    signer: any SuiSignerProtocol,
    options: TransactionResponseOptions = TransactionResponseOptions()
  ) async throws -> SuiTransactionBlockResponse {
    try transactionBlock.setSenderIfNotSet(sender: try signer.address())
    let txBytes = try await transactionBlock.build(provider: self, onlyTransactionKind: false)
    let signature = try signer.signTransactionBlock(txBytes)
    return try await executeTransactionBlock(
      txBytes: txBytes,
      signatures: [signature],
      options: options
    )
  }

  /// Build and dry-run a transaction block (full `TransactionData`).
  public func dryRunTransactionBlock(
    transactionBlock: any TransactionBlockProtocol
  ) async throws -> DryRunResult {
    let txBytes = try await transactionBlock.build(provider: self, onlyTransactionKind: false)
    return try await dryRunTransactionBlock(txBytes: txBytes)
  }

  /// Run a transaction in dev-inspect mode: build only the `TransactionKind`,
  /// then simulate it as the given sender. Returns the same simulation result
  /// shape as a dry run.
  public func devInspectTransactionBlock(
    transactionBlock: any TransactionBlockProtocol,
    sender: any SuiPublicKeyProtocol
  ) async throws -> DryRunResult {
    _ = try sender.toSuiAddress()
    let kindBytes = try await transactionBlock.build(provider: self, onlyTransactionKind: true)
    let result = try await GraphQLClient.fetchQuery(
      client: apollo,
      query: DevInspectTransactionBlockQuery(
        transaction: JSON(Data(kindBytes).base64EncodedString()),
        showBalanceChanges: true,
        showEffects: true,
        showRawEffects: false,
        showEvents: true,
        showObjectChanges: true
      )
    )
    let sim = try require(result.data?.simulateTransaction, "simulateTransaction")
    let fx = sim.effects
    let balanceChanges =
      fx?.balanceChanges?.nodes.map {
        BalanceChange(coinType: $0.coinType?.repr, owner: $0.owner?.address, amount: $0.amount)
      } ?? []
    return DryRunResult(
      error: nil,
      status: nil,
      executionError: nil,
      gasSummary: nil,
      balanceChanges: balanceChanges,
      effectsBcs: fx?.effectsBcs
    )
  }

  // MARK: - Name service endpoints

  /// Resolve a SuiNS domain name to its on-chain address.
  public func resolveNameServiceAddress(name: String) async throws -> String? {
    let result = try await GraphQLClient.fetchQuery(
      client: apollo,
      query: ResolveNameServiceAddressQuery(domain: name)
    )
    return result.data?.address?.address
  }

  /// Resolve an address to its default SuiNS name, if any.
  public func resolveNameServiceNames(address: String) async throws -> String? {
    let result = try await GraphQLClient.fetchQuery(
      client: apollo,
      query: ResolveNameServiceNamesQuery(address: address)
    )
    return result.data?.address?.defaultNameRecord?.domain
  }

  // MARK: - System / validators endpoints

  /// Return the latest Sui system state summary (current epoch).
  public func getLatestSuiSystemState() async throws -> SuiSystemStateSummary {
    let result = try await GraphQLClient.fetchQuery(
      client: apollo,
      query: GetLatestSuiSystemStateQuery()
    )
    let epoch = try require(result.data?.epoch, "epoch")
    return try SuiSystemStateSummary(graphql: epoch)
  }

  /// Return the protocol configuration for a version (latest if `nil`).
  public func getProtocolConfig(version: UInt64? = nil) async throws -> ProtocolConfig {
    let result = try await GraphQLClient.fetchQuery(
      client: apollo,
      query: GetProtocolConfigQuery(
        protocolVersion: version.map { .some(String($0)) } ?? .null
      )
    )
    let cfg = try require(result.data?.protocolConfigs, "protocolConfigs")
    return try ProtocolConfig(graphql: cfg)
  }

  /// Return the committee information for an epoch (latest if `nil`).
  public func getCommitteeInfo(epoch: UInt64? = nil) async throws -> CommitteeInfo {
    let result = try await GraphQLClient.fetchQuery(
      client: apollo,
      query: GetCommitteeInfoQuery(
        epochId: epoch.map { .some(String($0)) } ?? .null
      )
    )
    let e = try require(result.data?.epoch, "epoch")
    return try CommitteeInfo(graphql: e)
  }

  /// Return the active validator set for the current epoch.
  public func getValidatorsApy() async throws -> ValidatorApys {
    let result = try await GraphQLClient.fetchQuery(
      client: apollo,
      query: GetValidatorsApyQuery()
    )
    let e = try require(result.data?.epoch, "epoch")
    return try ValidatorApys(graphql: e)
  }

  // MARK: - Dynamic fields endpoint

  /// Return the dynamic fields owned by an object.
  public func getDynamicFields(
    parentId: String,
    limit: Int? = nil,
    cursor: String? = nil
  ) async throws -> DynamicFieldPage {
    let result = try await GraphQLClient.fetchQuery(
      client: apollo,
      query: GetDynamicFieldsQuery(
        parentId: parentId,
        first: limit.map { .some(Int32($0)) } ?? .null,
        cursor: cursor.map { .some($0) } ?? .null
      )
    )
    guard let fields = result.data?.address?.dynamicFields else {
      return Page(data: [], pageInfo: PageInfo())
    }
    return Page(
      data: try fields.nodes.map { try DynamicFieldInfo(graphql: $0) },
      pageInfo: PageInfo(graphql: fields.pageInfo)
    )
  }

  // MARK: - Move-normalized endpoints

  /// Return the normalized signature of a Move function.
  public func getNormalizedMoveFunction(
    packageId: String,
    module: String,
    function: String
  ) async throws -> SuiMoveNormalizedFunction? {
    let result = try await GraphQLClient.fetchQuery(
      client: apollo,
      query: GetNormalizedMoveFunctionQuery(
        packageId: packageId, module: module, function: function)
    )
    guard let fn = result.data?.object?.asMovePackage?.module?.function else { return nil }
    return SuiMoveNormalizedFunction(graphql: fn.fragments.rPC_MOVE_FUNCTION_FIELDS)
  }

  /// Return a normalized representation of a Move module.
  public func getNormalizedMoveModule(
    packageId: String,
    module: String
  ) async throws -> SuiMoveNormalizedModule? {
    let result = try await GraphQLClient.fetchQuery(
      client: apollo,
      query: GetNormalizedMoveModuleQuery(packageId: packageId, module: module)
    )
    guard let mod = result.data?.object?.asMovePackage?.module else { return nil }
    return SuiMoveNormalizedModule(graphql: mod.fragments.rPC_MOVE_MODULE_FIELDS)
  }

  /// Return normalized representations of all modules in a package, keyed by name.
  public func getNormalizedMoveModulesByPackage(
    packageId: String,
    cursor: String? = nil
  ) async throws -> [String: SuiMoveNormalizedModule] {
    let result = try await GraphQLClient.fetchQuery(
      client: apollo,
      query: GetNormalizedMoveModulesByPackageQuery(
        packageId: packageId,
        cursor: cursor.map { .some($0) } ?? .null
      )
    )
    let modules = result.data?.object?.asMovePackage?.modules?.nodes ?? []
    return modules.reduce(into: [:]) { acc, node in
      let m = SuiMoveNormalizedModule(graphql: node.fragments.rPC_MOVE_MODULE_FIELDS)
      acc[m.name] = m
    }
  }

  /// Return a normalized representation of a Move struct.
  public func getNormalizedMoveStruct(
    packageId: String,
    module: String,
    structure: String
  ) async throws -> SuiMoveNormalizedStruct? {
    let result = try await GraphQLClient.fetchQuery(
      client: apollo,
      query: GetNormalizedMoveStructQuery(packageId: packageId, module: module, struct: structure)
    )
    guard let s = result.data?.object?.asMovePackage?.module?.struct else { return nil }
    return SuiMoveNormalizedStruct(graphql: s.fragments.rPC_MOVE_STRUCT_FIELDS)
  }

  /// Return the parameter type signatures of a Move function (raw
  /// `OpenMoveTypeSignature` JSON strings).
  public func getMoveFunctionArgTypes(
    packageId: String,
    module: String,
    function: String
  ) async throws -> [String] {
    let result = try await GraphQLClient.fetchQuery(
      client: apollo,
      query: GetMoveFunctionArgTypesQuery(packageId: packageId, module: module, function: function)
    )
    let params = result.data?.object?.asMovePackage?.module?.function?.parameters ?? []
    return params.map { $0.signature.string }
  }

  // MARK: - Event endpoints

  /// Query Move events matching a filter, with pagination.
  public func queryEvents(
    filter: SuiEventFilter,
    limit: Int? = nil,
    cursor: String? = nil,
    order: SortOrder = .descending
  ) async throws -> SuiEventPage {
    let limit32 = limit.map { Int32($0) }
    let first: GraphQLNullable<Int32>
    let last: GraphQLNullable<Int32>
    let before: GraphQLNullable<String>
    let after: GraphQLNullable<String>
    switch order {
    case .descending:
      first = .null
      last = limit32.map { .some($0) } ?? .null
      before = cursor.map { .some($0) } ?? .null
      after = .null
    case .ascending:
      first = limit32.map { .some($0) } ?? .null
      last = .null
      before = .null
      after = cursor.map { .some($0) } ?? .null
    }
    let result = try await GraphQLClient.fetchQuery(
      client: apollo,
      query: QueryEventsQuery(
        filter: EventFilter(domain: filter),
        before: before,
        after: after,
        first: first,
        last: last
      )
    )
    let events = try require(result.data?.events, "events")
    return Page(
      data: try events.nodes.map { try SuiEvent(graphql: $0.fragments.rPC_EVENTS_FIELDS) },
      pageInfo: PageInfo(graphql: events.pageInfo)
    )
  }

  // MARK: - Transaction endpoints

  /// Options controlling which optional fields a transaction query fetches.
  public struct TransactionResponseOptions: Sendable, Equatable {
    public var showInput: Bool
    public var showEffects: Bool
    public var showEvents: Bool
    public var showBalanceChanges: Bool
    public var showObjectChanges: Bool

    public init(
      showInput: Bool = true,
      showEffects: Bool = true,
      showEvents: Bool = true,
      showBalanceChanges: Bool = true,
      showObjectChanges: Bool = true
    ) {
      self.showInput = showInput
      self.showEffects = showEffects
      self.showEvents = showEvents
      self.showBalanceChanges = showBalanceChanges
      self.showObjectChanges = showObjectChanges
    }
  }

  /// Return a transaction block by digest.
  public func getTransactionBlock(
    digest: String,
    options: TransactionResponseOptions = TransactionResponseOptions()
  ) async throws -> SuiTransactionBlockResponse {
    let result = try await GraphQLClient.fetchQuery(
      client: apollo,
      query: GetTransactionBlockQuery(
        digest: digest,
        showBalanceChanges: .some(options.showBalanceChanges),
        showEffects: .some(options.showEffects),
        showRawEffects: false,
        showEvents: .some(options.showEvents),
        showInput: .some(options.showInput),
        showObjectChanges: .some(options.showObjectChanges),
        showRawInput: false
      )
    )
    let tx = try require(result.data?.transaction, "transaction")
    return try SuiTransactionBlockResponse(graphql: tx.fragments.rPC_TRANSACTION_FIELDS)
  }

  /// Return multiple transaction blocks by digest. The result preserves order;
  /// missing transactions are omitted.
  public func multiGetTransactionBlocks(
    digests: [String],
    options: TransactionResponseOptions = TransactionResponseOptions()
  ) async throws -> [SuiTransactionBlockResponse] {
    let result = try await GraphQLClient.fetchQuery(
      client: apollo,
      query: MultiGetTransactionBlocksQuery(
        digests: digests,
        showBalanceChanges: .some(options.showBalanceChanges),
        showEffects: .some(options.showEffects),
        showRawEffects: false,
        showEvents: .some(options.showEvents),
        showInput: .some(options.showInput),
        showObjectChanges: .some(options.showObjectChanges),
        showRawInput: false
      )
    )
    let txs = try require(result.data?.multiGetTransactions, "multiGetTransactions")
    return try txs.compactMap { node in
      try node.map { try SuiTransactionBlockResponse(graphql: $0.fragments.rPC_TRANSACTION_FIELDS) }
    }
  }

  /// Query transaction blocks with pagination.
  public func queryTransactionBlocks(
    limit: Int? = nil,
    cursor: String? = nil,
    order: SortOrder = .descending,
    options: TransactionResponseOptions = TransactionResponseOptions()
  ) async throws -> SuiTransactionBlockResponsePage {
    let limit32 = limit.map { Int32($0) }
    let first: GraphQLNullable<Int32>
    let last: GraphQLNullable<Int32>
    let before: GraphQLNullable<String>
    let after: GraphQLNullable<String>
    switch order {
    case .descending:
      first = .null
      last = limit32.map { .some($0) } ?? .null
      before = cursor.map { .some($0) } ?? .null
      after = .null
    case .ascending:
      first = limit32.map { .some($0) } ?? .null
      last = .null
      before = .null
      after = cursor.map { .some($0) } ?? .null
    }
    let result = try await GraphQLClient.fetchQuery(
      client: apollo,
      query: QueryTransactionBlocksQuery(
        first: first,
        last: last,
        before: before,
        after: after,
        showBalanceChanges: .some(options.showBalanceChanges),
        showEffects: .some(options.showEffects),
        showRawEffects: false,
        showEvents: .some(options.showEvents),
        showInput: .some(options.showInput),
        showObjectChanges: .some(options.showObjectChanges),
        showRawInput: false,
        filter: .null
      )
    )
    let txs = try require(result.data?.transactions, "transactions")
    return Page(
      data: try txs.nodes.map {
        try SuiTransactionBlockResponse(graphql: $0.fragments.rPC_TRANSACTION_FIELDS)
      },
      pageInfo: PageInfo(graphql: txs.pageInfo)
    )
  }

  /// Return the object information for a specific past version.
  public func tryGetPastObject(
    objectId: String,
    version: UInt64,
    options: SuiObjectDataOptions = SuiObjectDataOptions()
  ) async throws -> SuiObjectResponse {
    let result = try await GraphQLClient.fetchQuery(
      client: apollo,
      query: TryGetPastObjectQuery(
        id: objectId,
        version: .some(String(version)),
        showBcs: .some(options.showBcs),
        showOwner: .some(options.showOwner),
        showPreviousTransaction: .some(options.showPreviousTransaction),
        showContent: .some(options.showContent),
        showDisplay: .some(options.showDisplay),
        showType: .some(options.showType),
        showStorageRebate: .some(options.showStorageRebate)
      )
    )
    guard let object = result.data?.object else {
      return SuiObjectResponse(data: nil, error: "notExists")
    }
    return SuiObjectResponse(
      data: try SuiObjectData(graphql: object.fragments.rPC_OBJECT_FIELDS),
      error: nil
    )
  }

  // MARK: - Checkpoint endpoints

  /// Return a checkpoint by its sequence number, or the latest if `nil`.
  public func getCheckpoint(sequenceNumber: UInt64? = nil) async throws -> Checkpoint {
    let seqArg: GraphQLNullable<UInt53> = sequenceNumber.map { .some(String($0)) } ?? .null
    let result = try await GraphQLClient.fetchQuery(
      client: apollo,
      query: GetCheckpointQuery(sequenceNumber: seqArg)
    )
    let cp = try require(result.data?.checkpoint, "checkpoint")
    return try Checkpoint(graphql: cp.fragments.rPC_Checkpoint_Fields)
  }

  /// Return a paginated list of checkpoints.
  /// - Parameters:
  ///   - cursor: Opaque paging cursor.
  ///   - limit: Maximum items per page.
  ///   - order: Result order. `.descending` (default) returns newest first.
  public func getCheckpoints(
    cursor: String? = nil,
    limit: Int? = nil,
    order: SortOrder = .descending
  ) async throws -> CheckpointPage {
    let limit32 = limit.map { Int32($0) }
    let query: GetCheckpointsQuery
    switch order {
    case .descending:
      query = GetCheckpointsQuery(
        first: .null,
        before: cursor.map { .some($0) } ?? .null,
        last: limit32.map { .some($0) } ?? .null,
        after: .null
      )
    case .ascending:
      query = GetCheckpointsQuery(
        first: limit32.map { .some($0) } ?? .null,
        before: .null,
        last: .null,
        after: cursor.map { .some($0) } ?? .null
      )
    }
    let result = try await GraphQLClient.fetchQuery(client: apollo, query: query)
    let checkpoints = try require(result.data?.checkpoints, "checkpoints")
    return Page(
      data: try checkpoints.nodes.map {
        try Checkpoint(graphql: $0.fragments.rPC_Checkpoint_Fields)
      },
      pageInfo: PageInfo(graphql: checkpoints.pageInfo)
    )
  }
}
