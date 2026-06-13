//
//  ReadEndpointTests.swift
//  LeanSuiApiTests
//
//  Live integration tests against Sui mainnet GraphQL. These hit the real
//  network to verify the provider's read endpoints decode actual on-chain
//  responses into the domain DTOs.
//
//  Run with:  swift test --filter LeanSuiApiTests
//  Set LEANSUI_LIVE=0 in the environment to skip the live network tests.
//

import BigInt
import XCTest

@testable import LeanSuiApi

final class ReadEndpointTests: XCTestCase {
  let provider = GraphQLSuiProvider(network: .mainnet)

  /// Known fixed mainnet chain identifier (first 4 bytes of genesis digest).
  static let mainnetChainId = "4btiuiMPvEENsttpZC7CZ53DruC3MAgfznDbASZ7DR6S"

  override func setUp() {
    super.setUp()
    if ProcessInfo.processInfo.environment["LEANSUI_LIVE"] == "0" {
      // Allow opting out of live network tests in CI.
      // (Individual tests check this and early-return via XCTSkip.)
    }
  }

  private func skipIfOffline() throws {
    if ProcessInfo.processInfo.environment["LEANSUI_LIVE"] == "0" {
      throw XCTSkip("Live network tests disabled (LEANSUI_LIVE=0).")
    }
  }

  // MARK: - Zero-input scalar endpoints

  func testChainIdentifier() async throws {
    try skipIfOffline()
    let id = try await provider.getChainIdentifier()
    XCTAssertEqual(id, Self.mainnetChainId, "mainnet chain identifier should be stable")
  }

  func testReferenceGasPrice() async throws {
    try skipIfOffline()
    let price = try await provider.getReferenceGasPrice()
    XCTAssertGreaterThan(price, 0, "reference gas price should be positive")
    print("referenceGasPrice = \(price)")
  }

  func testTotalTransactionBlocks() async throws {
    try skipIfOffline()
    let total = try await provider.getTotalTransactionBlocks()
    XCTAssertGreaterThan(total, 1_000_000_000, "mainnet has billions of tx blocks")
    print("totalTransactionBlocks = \(total)")
  }

  func testLatestCheckpointSequenceNumber() async throws {
    try skipIfOffline()
    let seq = try await provider.getLatestCheckpointSequenceNumber()
    XCTAssertGreaterThan(seq, 100_000_000)
    print("latestCheckpointSeq = \(seq)")
  }

  // MARK: - Coin endpoints (stable inputs)

  func testTotalSupplySUI() async throws {
    try skipIfOffline()
    let supply = try await provider.totalSupply("0x2::sui::SUI")
    XCTAssertGreaterThan(supply, 0)
    print("SUI totalSupply (base units) = \(supply)")
  }

  func testCoinMetadataSUI() async throws {
    try skipIfOffline()
    let meta = try await provider.getCoinMetadata(coinType: "0x2::sui::SUI")
    XCTAssertEqual(meta.symbol, "SUI")
    XCTAssertEqual(meta.decimals, 9)
    print("coinMetadata = \(meta)")
  }

  // MARK: - System / checkpoint

  func testLatestSuiSystemState() async throws {
    try skipIfOffline()
    let info = try await provider.getLatestSuiSystemState()
    XCTAssertGreaterThan(info.epoch, 0)
    XCTAssertNotNil(info.referenceGasPrice)
    XCTAssertNotNil(info.validatorSetJSON, "validator set raw JSON should be present")
    print(
      "epoch=\(info.epoch) refGas=\(String(describing: info.referenceGasPrice)) validatorJSONlen=\(info.validatorSetJSON?.count ?? 0)"
    )
  }

  func testGetCheckpointLatest() async throws {
    try skipIfOffline()
    let cp = try await provider.getCheckpoint()
    XCTAssertGreaterThan(cp.sequenceNumber, 0)
    XCTAssertNotNil(cp.digest)
    print(
      "checkpoint seq=\(cp.sequenceNumber) epoch=\(String(describing: cp.epoch)) txs=\(cp.transactionDigests.count)"
    )
  }

  func testGetCheckpointsPage() async throws {
    try skipIfOffline()
    let page = try await provider.getCheckpoints(limit: 3)
    XCTAssertEqual(page.data.count, 3)
    print("checkpoints page: \(page.data.map { $0.sequenceNumber })")
  }

  func testProtocolConfig() async throws {
    try skipIfOffline()
    let cfg = try await provider.getProtocolConfig()
    XCTAssertGreaterThan(cfg.protocolVersion, 0)
    XCTAssertFalse(cfg.featureFlags.isEmpty)
    print(
      "protocolVersion=\(cfg.protocolVersion) configs=\(cfg.configs.count) flags=\(cfg.featureFlags.count)"
    )
  }

  func testValidatorsApy() async throws {
    try skipIfOffline()
    let apys = try await provider.getValidatorsApy()
    XCTAssertGreaterThan(apys.epoch, 0)
    XCTAssertNotNil(apys.validatorSetJSON)
  }

  func testCommitteeInfo() async throws {
    try skipIfOffline()
    let committee = try await provider.getCommitteeInfo()
    XCTAssertGreaterThan(committee.epoch, 0)
    XCTAssertNotNil(committee.validatorSetJSON)
    print(
      "committee epoch=\(committee.epoch) validatorJSONlen=\(committee.validatorSetJSON?.count ?? 0)"
    )
  }

  func testResolveNameServiceName() async throws {
    try skipIfOffline()
    // 0x2 has no default SuiNS name; verify the call decodes without throwing.
    let name = try await provider.resolveNameServiceNames(address: "0x2")
    print("defaultSuinsName(0x2) = \(String(describing: name))")
  }
}
