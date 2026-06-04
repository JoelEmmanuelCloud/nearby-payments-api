//
//  LiveProviderSmokeTests.swift
//  LeanSui
//
//  Tier 2: live GraphQL-provider smoke tests. These hit a real Sui endpoint and
//  are therefore GATED behind the `SUI_E2E` environment variable — they SKIP by
//  default (and in CI) so the build never depends on network reachability.
//
//  Run them with:
//      SUI_E2E=1 swift test --filter LiveProviderSmokeTests
//  Optional overrides:
//      SUI_E2E_ENDPOINT  — GraphQL endpoint URL (defaults to testnet)
//      SUI_E2E_ADDRESS   — a funded address; enables the build(provider:) smoke
//
//  They prove the LeanSuiApi wiring that `TransactionBlock.build` depends on
//  (typed gas price, coins, normalized move functions, object reads) works
//  end-to-end. They are intentionally tolerant: reads against stable, always-
//  present on-chain state (the 0x5 system-state object, the 0x2 framework).
//

import Foundation
import LeanSuiApi
import XCTest

@testable import LeanSui

final class LiveProviderSmokeTests: XCTestCase {
  private func requireE2E() throws {
    try XCTSkipUnless(
      ProcessInfo.processInfo.environment["SUI_E2E"] == "1",
      "Set SUI_E2E=1 to run live provider smoke tests.")
  }

  private func makeProvider() -> GraphQLSuiProvider {
    let endpoint = ProcessInfo.processInfo.environment["SUI_E2E_ENDPOINT"]
    let network = SuiNetwork(kind: .testnet, endpoint: endpoint)
    return GraphQLSuiProvider(network: network)
  }

  func testChainIdentifier() async throws {
    try requireE2E()
    let id = try await makeProvider().getChainIdentifier()
    XCTAssertFalse(id.isEmpty)
  }

  // The exact value `TransactionBlock.build` reads for gas. Must be a positive UInt64.
  func testReferenceGasPrice() async throws {
    try requireE2E()
    let price = try await makeProvider().getReferenceGasPrice()
    XCTAssertGreaterThan(price, 0)
  }

  func testLatestCheckpoint() async throws {
    try requireE2E()
    let seq = try await makeProvider().getLatestCheckpointSequenceNumber()
    XCTAssertGreaterThan(seq, 0)
  }

  func testProtocolConfig() async throws {
    try requireE2E()
    // Should resolve without throwing.
    _ = try await makeProvider().getProtocolConfig()
  }

  // Exercises the normalized-move-function path used during transaction building.
  // Previously a known gap: the `OpenMoveTypeSignature` scalar was typed `String`
  // and Apollo failed to decode the structured server response. Now that the
  // scalar is a real custom scalar (LeanSuiApi), this resolves `0x2::coin::value`
  // (whose parameter is `&Coin<T>`) and surfaces its structured signature.
  func testNormalizedMoveFunction() async throws {
    try requireE2E()
    let fn = try await makeProvider().getNormalizedMoveFunction(
      packageId: "0x2", module: "coin", function: "value")
    let unwrapped = try XCTUnwrap(fn)
    XCTAssertEqual(unwrapped.name, "value")
    XCTAssertEqual(unwrapped.parameters.count, 1)
    // The structured `&Coin<T>` signature must round-trip into the builder's
    // parser — i.e. the wiring that arbitrary move-call building depends on.
    let parsed = SuiMoveNormalizedType.parseGraphQLSignature(unwrapped.parameters[0])
    XCTAssertNotNil(parsed, "OpenMoveTypeSignature did not parse: \(unwrapped.parameters[0])")
  }

  // 0x5 is the Sui system-state object — always present on every network.
  func testMultiObjectsReadsSystemState() async throws {
    try requireE2E()
    let objects = try await makeProvider().getMultiObjects(ids: ["0x5"])
    XCTAssertEqual(objects.count, 1)
  }

  // getCoins must not throw for a valid owner; the page may legitimately be empty.
  func testGetCoinsDoesNotThrow() async throws {
    try requireE2E()
    let owner =
      ProcessInfo.processInfo.environment["SUI_E2E_ADDRESS"]
      ?? "0x0000000000000000000000000000000000000000000000000000000000000000"
    _ = try await makeProvider().getCoins(owner: owner)
  }

  // Full end-to-end build: requires a funded address (gas resolution hits getCoins).
  // Skips unless SUI_E2E_ADDRESS is provided.
  func testBuildSplitAndTransferProducesTxBytes() async throws {
    try requireE2E()
    guard let sender = ProcessInfo.processInfo.environment["SUI_E2E_ADDRESS"] else {
      throw XCTSkip("Set SUI_E2E_ADDRESS (a funded address) to run the build smoke test.")
    }
    let provider = makeProvider()
    let tx = try TransactionBlock()
    try tx.setSender(sender: sender)
    tx.setGasBudget(price: 10_000_000)

    let coin = try tx.splitCoin(
      coin: .gasCoin,
      amounts: [.input(try tx.pure(data: Data([1, 0, 0, 0, 0, 0, 0, 0])))]
    )
    _ = try tx.transferObject(objects: [coin], address: sender)

    let txBytes = try await tx.build(provider, nil)
    XCTAssertFalse(txBytes.isEmpty)
  }

  // Arbitrary move-call building (the Tier 3 feature unblocked by structuring the
  // OpenMoveTypeSignature scalar). Builds a call to a framework function — its
  // parameter signature is resolved live via getNormalizedMoveFunction — and
  // serializes to txBytes. `0x1::ascii::string(vector<u8>)` takes a single pure
  // argument, so no object inputs are needed (only gas → a funded address).
  func testArbitraryMoveCallBuildProducesTxBytes() async throws {
    try requireE2E()
    guard let sender = ProcessInfo.processInfo.environment["SUI_E2E_ADDRESS"] else {
      throw XCTSkip("Set SUI_E2E_ADDRESS (a funded address) to run the move-call build test.")
    }
    let provider = makeProvider()
    let tx = try TransactionBlock()
    try tx.setSender(sender: sender)
    tx.setGasBudget(price: 10_000_000)

    // ascii::string(bytes: vector<u8>) — pass the bytes of "hi" as a pure arg.
    _ = try tx.moveCall(
      target: "0x1::ascii::string",
      arguments: [.input(try tx.pure(data: Data([2, 104, 105])))]  // ULEB len 2 + "hi"
    )

    let txBytes = try await tx.build(provider, nil)
    XCTAssertFalse(txBytes.isEmpty)
  }
}
