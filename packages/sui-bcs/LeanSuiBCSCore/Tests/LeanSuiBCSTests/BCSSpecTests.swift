//
//  BCSSpecTests.swift
//  SuiBCSTests
//
//  Validates the SuiBCS Serializer/Deserializer against the canonical BCS wire
//  format (little-endian integers, ULEB128 length prefixes, one-byte bools).
//  Vectors cross-checked against the Sui/Mysten `@mysten/bcs` TS SDK and the
//  Move BCS spec.
//

import Foundation
import UInt256
import XCTest

@testable import LeanSuiBCS

final class BCSSpecTests: XCTestCase {

  private func hex(_ data: SuiData) -> String {
    data.map { String(format: "%02x", $0) }.joined()
  }

  // MARK: - Integers (little-endian)

  func testU8() throws {
    let s = Serializer()
    try Serializer.u8(s, UInt8(0x01))
    XCTAssertEqual(hex(s.output()), "01")
  }

  func testU16LittleEndian() throws {
    let s = Serializer()
    try Serializer.u16(s, UInt16(0x1234))
    XCTAssertEqual(hex(s.output()), "3412")
  }

  func testU32LittleEndian() throws {
    let s = Serializer()
    try Serializer.u32(s, UInt32(0x1234_5678))
    XCTAssertEqual(hex(s.output()), "78563412")
  }

  func testU64LittleEndian() throws {
    let s = Serializer()
    try Serializer.u64(s, UInt64(1))
    XCTAssertEqual(hex(s.output()), "0100000000000000")
  }

  func testU128LittleEndian() throws {
    let s = Serializer()
    try Serializer.u128(s, UInt128(1))
    XCTAssertEqual(hex(s.output()), "01000000000000000000000000000000")
  }

  func testU256Is32BytesLittleEndian() throws {
    let s = Serializer()
    try Serializer.u256(s, UInt256(1))
    let out = s.output()
    XCTAssertEqual(out.count, 32)  // u256 is always 32 bytes
    // value 1, little-endian: 01 then 31 zero bytes
    XCTAssertEqual(hex(out), "01" + String(repeating: "00", count: 31))
  }

  func testU256RoundTrip() throws {
    for value: UInt256 in [UInt256(0), UInt256(1), UInt256(0xDEAD_BEEF), UInt256(UInt64.max)] {
      let s = Serializer()
      try Serializer.u256(s, value)
      let d = Deserializer(data: s.output())
      XCTAssertEqual(try Deserializer.u256(d), value, "round trip failed for \(value)")
    }
  }

  // MARK: - Strings (ULEB128 length + UTF-8 bytes)

  func testString() throws {
    let s = Serializer()
    try Serializer.str(s, "abc")
    XCTAssertEqual(hex(s.output()), "03616263")  // len 3 + "abc"
  }

  func testStringMultiByteLength() throws {
    // A 128-char string exercises a 2-byte ULEB128 length prefix (0x80 0x01).
    let s = Serializer()
    try Serializer.str(s, String(repeating: "a", count: 128))
    XCTAssertTrue(hex(s.output()).hasPrefix("8001"))
  }

  // MARK: - Bool (single byte, spec-compliant — not bit-packed)

  func testBool() throws {
    let t = Serializer()
    try Serializer.bool(t, true)
    XCTAssertEqual(hex(t.output()), "01")

    let f = Serializer()
    try Serializer.bool(f, false)
    XCTAssertEqual(hex(f.output()), "00")
  }

  func testBoolArrayIsOneBytePerElement() throws {
    let s = Serializer()
    try s.boolArray([true, false, true])
    XCTAssertEqual(hex(s.output()), "03" + "010001")
  }

  // MARK: - Round trips

  func testU64ArrayRoundTrip() throws {
    let values: [UInt64] = (0..<100).map { UInt64($0) * 0x0102_0304 }
    let s = Serializer()
    try s.serializeU64Array(values)
    let d = Deserializer(data: s.output())
    XCTAssertEqual(try d.deserializeU64Array(), values)
  }

  func testBoolArrayRoundTrip() throws {
    let values: [Bool] = (0..<100).map { $0 % 3 == 0 }
    let s = Serializer()
    try s.boolArray(values)
    let d = Deserializer(data: s.output())
    XCTAssertEqual(try d.deserializeBoolArray(), values)
  }

  func testU64StaticRoundTrip() throws {
    let s = Serializer()
    try Serializer.u64(s, UInt64(0xDEAD_BEEF))
    let d = Deserializer(data: s.output())
    XCTAssertEqual(try Deserializer.u64(d), UInt64(0xDEAD_BEEF))
  }

  func testStringRoundTrip() throws {
    let s = Serializer()
    try Serializer.str(s, "hello, sui")
    let d = Deserializer(data: s.output())
    XCTAssertEqual(try Deserializer.string(d), "hello, sui")
  }
}
