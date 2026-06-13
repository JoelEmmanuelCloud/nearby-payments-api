//
//  RecipientInputTests.swift
//  nearbyTests
//
//  Pure tests for recipient parsing/normalization (addresses + SuiNS names).
//

import Testing

@testable import nearby

struct RecipientInputTests {
  static let address = "0x" + String(repeating: "a", count: 64)

  @Test func blankIsEmpty() {
    #expect(RecipientInput.parse("   ") == .empty)
  }

  @Test func wellFormedAddress() {
    #expect(RecipientInput.parse(Self.address) == .address(Self.address))
    #expect(RecipientInput.parse("0xABC") == .address("0xabc"))  // lowercased, short is ok
  }

  @Test func malformedAddress() {
    #expect(RecipientInput.parse("0xZZ") == .invalid)  // non-hex
    #expect(RecipientInput.parse("0x" + String(repeating: "a", count: 65)) == .invalid)  // too long
  }

  @Test func bareNameGetsSuiSuffix() {
    #expect(RecipientInput.parse("alice") == .name("alice.sui"))
    #expect(RecipientInput.parse("alice.nearby") == .name("alice.nearby.sui"))
  }

  @Test func suiSuffixKept() {
    #expect(RecipientInput.parse("alice.sui") == .name("alice.sui"))
    #expect(RecipientInput.parse(" ALICE.SUI ") == .name("alice.sui"))  // trimmed + lowercased
  }

  @Test func malformedName() {
    #expect(RecipientInput.parse("ali ce") == .invalid)  // space in label
    #expect(RecipientInput.parse("..sui") == .invalid)  // empty label
  }
}
