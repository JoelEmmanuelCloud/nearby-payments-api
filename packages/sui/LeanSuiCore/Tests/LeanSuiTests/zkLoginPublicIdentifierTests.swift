//
//  zkLoginPublicIdentifierTests.swift
//  LeanSui
//
//  Offline zkLoginPublicIdentifier vectors ported from SuiKit
//  (Tests/SuiKitTests/Unit/zkLogin/zkLoginPublicIdentifierTests.swift),
//  matching the @mysten/sui TypeScript tests. Pure; no network.
//

import BigInt
import XCTest

@testable import LeanSui

final class zkLoginPublicIdentifierTests: XCTestCase {
  func testzkLoginPublicIdentifierAddress() throws {
    let addressSeed = BigInt(
      "380704556853533152350240698167704405529973457670972223618755249929828551006")
    let pubId = try zkLoginPublicIdentifier(
      addressSeed: addressSeed,
      iss: "https://accounts.google.com"
    )
    // Current (unpadded) address. SuiKit asserted the legacy 0x3f8f… here, which
    // contradicted its own zkLoginAddressTests; 0xbd8b… is the correct value.
    let computedAddress = try pubId.toSuiAddress()
    XCTAssertEqual(
      computedAddress, "0xbd8b8ed42d90aebc71518385d8a899af14cef8b5a171c380434dd6f5bbfe7bf3")
    // Legacy (padded) form remains available.
    XCTAssertEqual(
      try pubId.toLegacySuiAddress(),
      "0x3f8f50fc9440351a8d16a6b473493099dc988758e9edef64a93abfe7d435d527")
  }

  func testDifferentIssuerFormatsProduceSameAddress() throws {
    let seed = "380704556853533152350240698167704405529973457670972223618755249929828551006"

    let pubId1 = try zkLoginPublicIdentifier(
      addressSeed: seed,
      iss: "https://accounts.google.com"
    )
    let pubId2 = try zkLoginPublicIdentifier(
      addressSeed: seed,
      iss: "accounts.google.com"
    )
    XCTAssertEqual(try pubId1.toSuiAddress(), try pubId2.toSuiAddress())
  }

  func testParsezkLoginSignatureToPublicIdentifier() throws {
    let expectedAddress = "0xf7badc2b245c7f74d7509a4aa357ecf80a29e7713fb4c44b0e7541ec43885ee1"
    let publicKey = try zkLoginPublicIdentifier(
      addressSeed:
        "13322897930163218532266430409510394316985274769125667290600321564259466511711",
      iss: "https://accounts.google.com"
    )
    XCTAssertEqual(try publicKey.toSuiAddress(), expectedAddress)
  }

  func testPublicKeyBase58Representation() throws {
    let seed = BigInt(
      "380704556853533152350240698167704405529973457670972223618755249929828551006")
    let pubId = try zkLoginPublicIdentifier(
      addressSeed: seed,
      iss: "https://accounts.google.com"
    )

    let base58 = try pubId.toBase58()
    XCTAssertFalse(base58.isEmpty)

    let recreatedPubId = try zkLoginPublicIdentifier.fromBase58(base58)
    XCTAssertEqual(try recreatedPubId.toSuiAddress(), try pubId.toSuiAddress())
  }
}
