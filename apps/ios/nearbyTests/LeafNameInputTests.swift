//
//  LeafNameInputTests.swift
//  nearbyTests
//
//  Pure tests for Nearby leaf-name validation (no auto-stripping; a space is invalid).
//

import Testing

@testable import nearby

struct LeafNameInputTests {
  @Test func blankIsEmpty() {
    #expect(LeafNameInput.parse("   ") == .empty)
  }

  @Test func validLabelNormalizes() {
    #expect(LeafNameInput.parse("alice") == .valid("alice"))
    #expect(LeafNameInput.parse("  ALICE  ") == .valid("alice"))
    #expect(LeafNameInput.parse("a-1") == .valid("a-1"))
  }

  @Test func spaceOrSymbolIsInvalid() {
    #expect(LeafNameInput.parse("ali ce") == .invalid)
    #expect(LeafNameInput.parse("alice!") == .invalid)
    #expect(LeafNameInput.parse("ali.ce") == .invalid)
  }
}
