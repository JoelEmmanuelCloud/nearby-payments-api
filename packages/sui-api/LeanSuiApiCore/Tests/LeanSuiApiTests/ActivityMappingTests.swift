//
//  ActivityMappingTests.swift
//  LeanSuiApiTests
//
//  Pure (no network) tests for folding a transaction's balance changes into a `SuiActivity` row.
//

import XCTest

@testable import LeanSuiApi

final class ActivityMappingTests: XCTestCase {
  static let me = "0x000000000000000000000000000000000000000000000000000000000000aaaa"
  static let other = "0x000000000000000000000000000000000000000000000000000000000000bbbb"
  static let coin = "0xa1ec7fc00a6f40db9693ad1415d0c193ad3906494428cf252621037bd7117e29::usdc::USDC"

  private func tx(
    digest: String = "DiGeStAbC",
    sender: String?,
    status: TransactionExecutionStatus = .success,
    balanceChanges: [BalanceChange]
  ) -> SuiTransactionBlockResponse {
    SuiTransactionBlockResponse(
      digest: digest,
      sender: sender,
      signatures: [],
      rawTransaction: nil,
      effects: TransactionEffects(
        status: status,
        executionError: nil,
        checkpointSequenceNumber: nil,
        timestamp: Date(timeIntervalSince1970: 1_700_000_000),
        bcs: nil,
        balanceChanges: balanceChanges
      )
    )
  }

  func testReceivedSetsDirectionAmountAndCounterparty() {
    let transaction = tx(
      sender: Self.other,
      balanceChanges: [
        BalanceChange(coinType: Self.coin, owner: Self.other, amount: "-12500000"),
        BalanceChange(coinType: Self.coin, owner: Self.me, amount: "12500000"),
      ]
    )

    let activity = SuiActivity.make(
      from: transaction, owner: Self.me, coinType: Self.coin, coinSymbol: "USDC", decimals: 6)

    let unwrapped = try? XCTUnwrap(activity)
    XCTAssertEqual(unwrapped?.direction, .received)
    XCTAssertEqual(unwrapped?.amount, "12.50")
    XCTAssertEqual(unwrapped?.coinSymbol, "USDC")
    XCTAssertEqual(unwrapped?.counterparty, Self.other)
    XCTAssertEqual(unwrapped?.succeeded, true)
    XCTAssertEqual(unwrapped?.details.coinChanges.count, 2)
  }

  func testSentSetsDirectionAndRecipientCounterparty() {
    let transaction = tx(
      sender: Self.me,
      balanceChanges: [
        BalanceChange(coinType: Self.coin, owner: Self.me, amount: "-5000000"),
        BalanceChange(coinType: Self.coin, owner: Self.other, amount: "5000000"),
      ]
    )

    let activity = SuiActivity.make(
      from: transaction, owner: Self.me, coinType: Self.coin, coinSymbol: "USDC", decimals: 6)

    XCTAssertEqual(activity?.direction, .sent)
    XCTAssertEqual(activity?.amount, "5.00")
    XCTAssertEqual(activity?.counterparty, Self.other)
  }

  func testUnrelatedCoinIsDropped() {
    let transaction = tx(
      sender: Self.other,
      balanceChanges: [
        BalanceChange(coinType: "0x2::sui::SUI", owner: Self.me, amount: "-1000")
      ]
    )

    let activity = SuiActivity.make(
      from: transaction, owner: Self.me, coinType: Self.coin, coinSymbol: "USDC", decimals: 6)

    XCTAssertNil(activity)
  }

  func testCoinChangeNotTouchingOwnerIsDropped() {
    let transaction = tx(
      sender: Self.other,
      balanceChanges: [
        BalanceChange(coinType: Self.coin, owner: Self.other, amount: "5000000")
      ]
    )

    let activity = SuiActivity.make(
      from: transaction, owner: Self.me, coinType: Self.coin, coinSymbol: "USDC", decimals: 6)

    XCTAssertNil(activity)
  }

  func testCoinTypeMatchIgnoresAddressPadding() {
    // Same coin, but the change's type has an unpadded `0x` address.
    let unpadded = "0xa1ec7fc00a6f40db9693ad1415d0c193ad3906494428cf252621037bd7117e29::usdc::USDC"
    let transaction = tx(
      sender: Self.other,
      balanceChanges: [
        BalanceChange(coinType: unpadded, owner: Self.me, amount: "1000000")
      ]
    )

    let activity = SuiActivity.make(
      from: transaction, owner: Self.me, coinType: Self.coin, coinSymbol: "USDC", decimals: 6)

    XCTAssertEqual(activity?.amount, "1.00")
  }

  func testFormatMagnitudeScalesAndPads() {
    XCTAssertEqual(SuiActivity.formatMagnitude("12500000", decimals: 6), "12.50")
    XCTAssertEqual(SuiActivity.formatMagnitude("1", decimals: 6), "0.00")
    XCTAssertEqual(SuiActivity.formatMagnitude("0", decimals: 6), "0.00")
    XCTAssertEqual(SuiActivity.formatMagnitude("123456", decimals: 0), "123456.00")
  }
}
