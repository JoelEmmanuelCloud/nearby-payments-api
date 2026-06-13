//
//  JWTUtilsTest.swift
//  LeanSui
//
//  Offline JWT-claim + nonce vectors ported from SuiKit
//  (Tests/SuiKitTests/Unit/zkLogin/JWTUtilsTest.swift). Pure; no network.
//

import XCTest

@testable import LeanSui

final class JWTUtilsTest: XCTestCase {
  func testThatClaimValuesAreExtractedAsIntended() throws {
    let extractedValue: String = try JWTUtilities.extractClaimValue(
      claim: zkLoginSignatureInputsClaim(
        value: "yJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLC",
        indexMod4: 1
      ),
      claimName: "iss"
    )
    XCTAssertEqual(extractedValue, "https://accounts.google.com")
  }

  func testThatGeneratingNonceWorksAsIntended() throws {
    let pk = try ED25519PublicKey(value: "dkUcNsSSYV2cFz+L/WAlyxINuXHpah/MJnYZ57/GtKY=")
    let nonce = try zkLoginNonce.generateNonce(
      publicKey: pk,
      maxEpoch: 954,
      randomness: "176720613486626510701195520524108477720"
    )
    XCTAssertEqual("NN9BV-W7MlsscmY042AddYkO1N8", nonce)
  }
}
