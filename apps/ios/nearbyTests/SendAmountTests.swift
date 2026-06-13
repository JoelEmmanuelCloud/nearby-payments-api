//
//  SendAmountTests.swift
//  nearbyTests
//
//  Pure tests for the send-amount keypad model and the predictive quick-select logic.
//

import Foundation
import Testing

@testable import nearby

struct AmountInputTests {
  @Test func replacesLeadingZeroAndAppends() {
    var input = AmountInput(maxFractionDigits: 6)
    #expect(input.display == "0")
    input.append(digit: 0)
    #expect(input.text == "0")
    input.append(digit: 5)
    #expect(input.text == "5")  // lone leading zero replaced, never "05"
    input.append(digit: 0)
    #expect(input.text == "50")
  }

  @Test func singleDecimalPointAndFractionCap() {
    var input = AmountInput(maxFractionDigits: 2)
    input.appendDecimal()
    #expect(input.text == "0.")
    input.appendDecimal()  // second decimal ignored
    #expect(input.text == "0.")
    input.append(digit: 1)
    input.append(digit: 2)
    #expect(input.text == "0.12")
    input.append(digit: 3)  // exceeds 2 fraction digits → ignored
    #expect(input.text == "0.12")
  }

  @Test func validityAndValue() {
    var input = AmountInput(maxFractionDigits: 6)
    #expect(!input.isValid)
    input.append(digit: 0)
    #expect(!input.isValid)  // "0" is not > 0
    input.append(digit: 5)
    #expect(input.isValid)
    #expect(input.decimalValue == 5)
  }

  @Test func backspaceRemovesLast() {
    var input = AmountInput(maxFractionDigits: 6)
    input.append(digit: 1)
    input.append(digit: 2)
    input.backspace()
    #expect(input.text == "1")
  }

  @Test func setFormatsPlainly() {
    var input = AmountInput(maxFractionDigits: 6)
    input.set(5000)
    #expect(input.text == "5000")
    input.set(Decimal(string: "55.5")!)
    #expect(input.text == "55.5")
  }
}

struct QuickSelectTests {
  @Test func defaultsWhenNothingTyped() {
    #expect(QuickSelect.suggestions(forValue: 0) == [10, 2000, 5000])
  }

  @Test func scalesTypedValueByTenHundredThousand() {
    #expect(QuickSelect.suggestions(forValue: 5) == [50, 500, 5000])
    #expect(QuickSelect.suggestions(forValue: 12) == [120, 1200, 12000])
  }
}
