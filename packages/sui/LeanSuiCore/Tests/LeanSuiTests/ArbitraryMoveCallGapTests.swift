//
//  ArbitraryMoveCallGapTests.swift
//  LeanSui
//
//  Tier 3: move-call signature-parser conformance.
//
//  The arbitrary move-call gap is CLOSED. It was never in the builder: the parser
//  `SuiMoveNormalizedType.parseGraphQLSignature` already handled the structured
//  signatures the server returns. The blocker was purely the Apollo scalar —
//  LeanSuiApi typed `OpenMoveTypeSignature` as `String`, so Apollo failed to
//  decode the structured object. Part (b) made it a real custom scalar (see
//  `LeanSuiApi/Schema/CustomScalars/OpenMoveTypeSignature.swift`), so parameters
//  now flow straight into the parser and `getNormalizedMoveFunction` /
//  `build(provider:)` move-call resolution work end-to-end (verified live in
//  `LiveProviderSmokeTests`).
//
//  These offline tests pin the parser's handling of the structured signature
//  shapes — references, generics, primitives — so a regression there can't creep
//  back in.
//

import XCTest

@testable import LeanSui

final class ArbitraryMoveCallGapTests: XCTestCase {
  // A reference to a generic struct: `&Coin<T>` — exactly what testnet returns for
  // `0x2::coin::value`'s parameter. Proves the parser handles refs + datatypes +
  // type parameters.
  func testParserHandlesReferenceToGenericStruct() {
    let sig = #"""
      {"ref":"&","body":{"datatype":{"type":"Coin","typeParameters":[{"typeParameter":0}],"package":"0x0000000000000000000000000000000000000000000000000000000000000002","module":"coin"}}}
      """#
    let parsed = SuiMoveNormalizedType.parseGraphQLSignature(sig)
    guard case .reference(let inner)? = parsed else {
      return XCTFail("expected .reference, got \(String(describing: parsed))")
    }
    guard case .structure(let structType) = inner else {
      return XCTFail("expected referenced .structure, got \(inner)")
    }
    XCTAssertEqual(structType.name, "Coin")
    XCTAssertEqual(structType.module, "coin")
  }

  // `&mut` references parse to `.mutableReference`.
  func testParserHandlesMutableReference() {
    let sig =
      #"{"ref":"&mut","body":{"datatype":{"type":"TxContext","typeParameters":[],"package":"0x0000000000000000000000000000000000000000000000000000000000000002","module":"tx_context"}}}"#
    guard case .mutableReference? = SuiMoveNormalizedType.parseGraphQLSignature(sig) else {
      return XCTFail("expected .mutableReference")
    }
  }

  // Primitive parameters parse directly.
  func testParserHandlesPrimitives() {
    XCTAssertEqual(SuiMoveNormalizedType.parseGraphQLSignature(#"{"body":"u64"}"#), .u64)
    XCTAssertEqual(SuiMoveNormalizedType.parseGraphQLSignature(#"{"body":"bool"}"#), .bool)
    XCTAssertEqual(SuiMoveNormalizedType.parseGraphQLSignature(#"{"body":"address"}"#), .address)
  }

  // Garbage / non-signature input yields nil (the builder turns this into the
  // explicit "Arbitrary move-call … not yet supported" error).
  func testParserRejectsInvalidSignature() {
    XCTAssertNil(SuiMoveNormalizedType.parseGraphQLSignature("not a signature"))
    XCTAssertNil(SuiMoveNormalizedType.parseGraphQLSignature(""))
  }
}
