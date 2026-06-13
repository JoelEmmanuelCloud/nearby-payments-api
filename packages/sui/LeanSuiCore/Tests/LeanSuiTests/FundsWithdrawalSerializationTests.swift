//
//  FundsWithdrawalSerializationTests.swift
//  LeanSui
//
//  Byte-exact BCS coverage for the Address Balances (gasless) additions:
//  `FundsWithdrawalArg` (the new `CallArg::FundsWithdrawal` input) and the
//  `TransactionExpiration.validDuring` variant. The expected byte layouts are
//  derived from the canonical `sui-types::transaction` Rust definitions (the
//  source the @mysten/sui BCS is generated from):
//
//    FundsWithdrawalArg = reservation || type_arg || withdraw_from
//      reservation   = uleb(0) || u64-le(amount)          // MaxAmountU64
//      type_arg      = uleb(0) || TypeTag                  // Balance(TypeTag)
//      withdraw_from = uleb(0|1)                           // Sender | Sponsor
//
//    TransactionExpiration::ValidDuring (variant 2) =
//      u8(2) || opt<u64> minEpoch || opt<u64> maxEpoch
//            || opt<u64> minTimestamp || opt<u64> maxTimestamp
//            || [u8; 32] chain || u32-le(nonce)
//

import Foundation
import LeanSuiBCS
import XCTest

@testable import LeanSui

final class FundsWithdrawalSerializationTests: XCTestCase {
  private func leU64(_ value: UInt64) -> [UInt8] {
    (0..<8).map { UInt8((value >> (8 * $0)) & 0xFF) }
  }

  private func leU32(_ value: UInt32) -> [UInt8] {
    (0..<4).map { UInt8((value >> (8 * $0)) & 0xFF) }
  }

  func testFundsWithdrawalArgByteLayout() throws {
    let coinType = "0x2::sui::SUI"
    let amount: UInt64 = 1_000_000

    let arg = try FundsWithdrawalArg.balanceFromSender(amount: amount, balanceType: coinType)
    let ser = Serializer()
    try Serializer._struct(ser, value: arg)
    let actual = ser.output().bytes

    // The TypeTag serialization is pre-existing/trusted; reuse it for the inner bytes so the
    // assertion isolates the wrapper layout (variant indices, amount, field order) that is new.
    let typeTagSer = Serializer()
    try Serializer._struct(typeTagSer, value: try TypeTag(stringValue: coinType))
    let typeTagBytes = typeTagSer.output().bytes

    var expected: [UInt8] = []
    expected += [0x00]  // Reservation::MaxAmountU64 variant
    expected += leU64(amount)  // amount, little-endian
    expected += [0x00]  // WithdrawalTypeArg::Balance variant
    expected += typeTagBytes  // TypeTag(0x2::sui::SUI)
    expected += [0x00]  // WithdrawFrom::Sender variant

    XCTAssertEqual(actual, expected)
  }

  func testFundsWithdrawalArgRoundTrips() throws {
    // Uses a primitive `TypeTag` so the round-trip exercises *this file's* new deserialize logic
    // (reservation / type-arg variant / withdraw-from) without depending on the SDK's pre-existing
    // struct-`TypeTag` deserialize asymmetry. The write path only ever serializes; struct coin
    // types are covered byte-exactly in `testFundsWithdrawalArgByteLayout`.
    let arg = FundsWithdrawalArg(
      reservation: .maxAmountU64(42),
      typeArg: .balance(try TypeTag(stringValue: "u64")),
      withdrawFrom: .sender
    )
    let ser = Serializer()
    try Serializer._struct(ser, value: arg)
    let bytes = ser.output()

    let der = Deserializer(bytes: bytes.bytes)
    let decoded: FundsWithdrawalArg = try Deserializer._struct(der)

    let reser = Serializer()
    try Serializer._struct(reser, value: decoded)
    XCTAssertEqual(reser.output().bytes, bytes.bytes)

    guard case .maxAmountU64(let value) = decoded.reservation else {
      return XCTFail("expected MaxAmountU64")
    }
    XCTAssertEqual(value, 42)
    guard case .sender = decoded.withdrawFrom else {
      return XCTFail("expected Sender")
    }
  }

  func testValidDuringExpirationByteLayout() throws {
    let chain = [UInt8](repeating: 0xAB, count: 32)
    let nonce: UInt32 = 7
    let epoch: UInt64 = 5

    let expiration = TransactionExpiration.validDuring(
      minEpoch: epoch,
      maxEpoch: epoch,
      minTimestamp: nil,
      maxTimestamp: nil,
      chain: chain,
      nonce: nonce
    )
    let ser = Serializer()
    try Serializer._struct(ser, value: expiration)
    let actual = ser.output().bytes

    var expected: [UInt8] = []
    expected += [0x02]  // ValidDuring variant
    expected += [0x01] + leU64(epoch)  // Some(minEpoch)
    expected += [0x01] + leU64(epoch)  // Some(maxEpoch)
    expected += [0x00]  // None minTimestamp
    expected += [0x00]  // None maxTimestamp
    expected += [0x20]  // ULEB length prefix for the 32-byte chain (Digest is serde `Bytes`)
    expected += chain  // 32 bytes
    expected += leU32(nonce)

    XCTAssertEqual(actual, expected)
  }

  func testValidDuringExpirationRoundTrips() throws {
    let chain = (0..<32).map { UInt8($0) }
    let expiration = TransactionExpiration.validDuring(
      minEpoch: 9,
      maxEpoch: 9,
      minTimestamp: nil,
      maxTimestamp: nil,
      chain: chain,
      nonce: 123_456
    )
    let ser = Serializer()
    try Serializer._struct(ser, value: expiration)
    let bytes = ser.output()

    let der = Deserializer(bytes: bytes.bytes)
    let decoded: TransactionExpiration = try Deserializer._struct(der)

    let reser = Serializer()
    try Serializer._struct(reser, value: decoded)
    XCTAssertEqual(reser.output().bytes, bytes.bytes)

    guard
      case .validDuring(let minEpoch, let maxEpoch, _, _, let decodedChain, let nonce) = decoded
    else {
      return XCTFail("expected validDuring")
    }
    XCTAssertEqual(minEpoch, 9)
    XCTAssertEqual(maxEpoch, 9)
    XCTAssertEqual(decodedChain, chain)
    XCTAssertEqual(nonce, 123_456)
  }

  /// The withdrawal must serialize as `CallArg` variant 2 when wrapped in an `Input`, so it lands
  /// after `Pure` (0) and `Object` (1) in a programmable transaction's input list.
  func testInputCallArgVariantIndex() throws {
    let arg = try FundsWithdrawalArg.balanceFromSender(
      amount: 1, balanceType: "0x2::sui::SUI")
    let input = Input(type: .fundsWithdrawal(arg))
    let ser = Serializer()
    try Serializer._struct(ser, value: input)
    XCTAssertEqual(ser.output().bytes.first, 0x02)
    XCTAssertEqual(input.kind, "fundsWithdrawal")
  }
}
