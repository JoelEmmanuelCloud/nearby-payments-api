//
//  zkLoginAddressTests.swift
//  LeanSui
//
//  Offline zkLogin address-derivation vectors ported from SuiKit
//  (Tests/SuiKitTests/Unit/zkLogin/zkLoginAddressTests.swift), which in turn
//  match the @mysten/sui TypeScript vectors. Pure input→output; no network.
//

import BigInt
import XCTest

@testable import LeanSui

final class zkLoginAddressTests: XCTestCase {
  func testThatVerifieszkLoginFunctionsGenerateTheCorrectAddressAsIntended() throws {
    let computedAddress = try zkLoginPublicIdentifier(
      addressSeed: BigInt(
        "13322897930163218532266430409510394316985274769125667290600321564259466511711"),
      iss: "https://accounts.google.com")
    try XCTAssertEqual(
      "0xf7badc2b245c7f74d7509a4aa357ecf80a29e7713fb4c44b0e7541ec43885ee1",
      computedAddress.toSuiAddress())
  }

  // The "short address seed" (< 32 bytes) case, where padded != unpadded.
  // Canonical/current Sui derives from the UNPADDED seed (base_types.rs
  // try_from_unpadded) → 0xbd8b…; the legacy (padded) address is 0x3f8f….
  // NOTE: SuiKit's own zkLoginAddressTests historically asserted 0xbd8b here
  // while its zkLoginPublicIdentifierTests asserted 0x3f8f for the same input —
  // a self-contradiction caused by the padded/unpadded bug. 0xbd8b is correct.
  func testThatVerifieszkLoginFunctionsGenerateTheCorrectAddressWithLeadingZeros() throws {
    let computedAddress = try zkLoginPublicIdentifier(
      addressSeed: BigInt(
        "380704556853533152350240698167704405529973457670972223618755249929828551006"),
      iss: "https://accounts.google.com")
    // Current (unpadded) address.
    try XCTAssertEqual(
      "0xbd8b8ed42d90aebc71518385d8a899af14cef8b5a171c380434dd6f5bbfe7bf3",
      computedAddress.toSuiAddress())
    // Legacy (padded) address, still derivable for migration/lookup.
    try XCTAssertEqual(
      "0x3f8f50fc9440351a8d16a6b473493099dc988758e9edef64a93abfe7d435d527",
      computedAddress.toLegacySuiAddress())
  }

  func testThatAValidJWTTokenShouldConvertOverToAnAddressWithNoErrorsAsIntended() throws {
    let jwt =
      "eyJraWQiOiJzdWkta2V5LWlkIiwidHlwIjoiSldUIiwiYWxnIjoiUlMyNTYifQ.eyJzdWIiOiI4YzJkN2Q2Ni04N2FmLTQxZmEtYjZmYy02M2U4YmI3MWZhYjQiLCJhdWQiOiJ0ZXN0IiwibmJmIjoxNjk3NDY1NDQ1LCJpc3MiOiJodHRwczovL29hdXRoLnN1aS5pbyIsImV4cCI6MTY5NzU1MTg0NSwibm9uY2UiOiJoVFBwZ0Y3WEFLYlczN3JFVVM2cEVWWnFtb0kifQ."
    let userSalt = "248191903847969014646285995941615069143"
    let address = try zkLoginUtilities.jwtToAddress(jwt: jwt, userSalt: userSalt)
    XCTAssertEqual(
      address, "0x22cebcf68a9d75d508d50d553dd6bae378ef51177a3a6325b749e57e3ba237d6")
  }

  func testThatVerifiesThatTheSameAddressIsReturnedByBothGoogleISSValuesAsIntended() throws {
    // iss: "https://accounts.google.com"
    let jwt1 =
      "eyJhbGciOiJSUzI1NiIsImtpZCI6InN1aS1rZXktaWQiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJzdWIiOiIxMjM0NTY3ODkwIiwiYXVkIjoiMTIzNDU2Nzg5MC5hcHBzLmdvb2dsZXVzZXJjb250ZW50LmNvbSIsImV4cCI6MTY5NzU1MTg0NSwiaWF0IjoxNjk3NDY1NDQ1fQ."
    // iss: "accounts.google.com"
    let jwt2 =
      "eyJhbGciOiJSUzI1NiIsImtpZCI6InN1aS1rZXktaWQiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJhY2NvdW50cy5nb29nbGUuY29tIiwic3ViIjoiMTIzNDU2Nzg5MCIsImF1ZCI6IjEyMzQ1Njc4OTAuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJleHAiOjE2OTc1NTE4NDUsImlhdCI6MTY5NzQ2NTQ0NX0."

    XCTAssertEqual(
      try zkLoginUtilities.jwtToAddress(jwt: jwt1, userSalt: "0"),
      try zkLoginUtilities.jwtToAddress(jwt: jwt2, userSalt: "0"))
  }

  func testThatHeadersThatAreTooLongThrowAnError() {
    func tooLongHeader() throws {
      let header = String(repeating: "a", count: (zkLoginUtilities.maxHeaderLengthBase64 + 1))
      let jwt = "\(header)."
      try zkLoginUtilities.lengthChecks(jwt: jwt)
    }
    XCTAssertThrowsError(try tooLongHeader())
  }

  func testThatJWTTokensThatAreTooLongThrowAnError() {
    func tooLongJWT() throws {
      let jwt = ".\(String(repeating: "a", count: zkLoginUtilities.maxPaddedUnsignedJwtLength))"
      try zkLoginUtilities.lengthChecks(jwt: jwt)
    }
    XCTAssertThrowsError(try tooLongJWT())
  }
}
