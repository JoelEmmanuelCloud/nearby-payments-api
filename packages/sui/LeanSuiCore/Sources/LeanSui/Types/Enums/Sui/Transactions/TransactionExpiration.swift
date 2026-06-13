//
//  TransactionExpiration.swift
//  SuiKit
//
//  Copyright (c) 2024-2025 OpenDive
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import LeanSuiBCS

/// Represents the expiration options for a transaction.
public enum TransactionExpiration: SuiBCSBridged {
  /// No expiration for the transaction.
  case none

  /// Expiration time set as an epoch timestamp.
  case epoch(UInt64)

  /// Bounded validity window with a nonce. Required for transactions whose gas is paid from an
  /// address balance (gasless): without a mutated gas-coin object there is no natural transaction
  /// uniqueness, so validators rely on the `chain` + `nonce` + epoch bounds for replay protection.
  /// `chain` is the 32-byte genesis checkpoint digest (the full chain identifier).
  case validDuring(
    minEpoch: UInt64?,
    maxEpoch: UInt64?,
    minTimestamp: UInt64?,
    maxTimestamp: UInt64?,
    chain: [UInt8],
    nonce: UInt32
  )

  public func serialize(_ serializer: Serializer) throws {
    switch self {
    case .none:
      try Serializer.u8(serializer, UInt8(0))
    case .epoch(let int):
      try Serializer.u8(serializer, UInt8(1))
      try Serializer.u64(serializer, UInt64(int))
    case .validDuring(
      let minEpoch, let maxEpoch, let minTimestamp, let maxTimestamp, let chain, let nonce):
      try Serializer.u8(serializer, UInt8(2))
      try Self.serializeOptionalU64(serializer, minEpoch)
      try Self.serializeOptionalU64(serializer, maxEpoch)
      try Self.serializeOptionalU64(serializer, minTimestamp)
      try Self.serializeOptionalU64(serializer, maxTimestamp)
      // `chain` is a `Digest([u8; 32])` annotated `serde_as(as = "Bytes")`, so BCS encodes it as a
      // length-prefixed byte buffer (`ULEB(32) || 32 bytes`) — NOT a raw fixed array.
      try serializer.uleb128(UInt(chain.count))
      serializer.fixedBytes(chain)
      try Serializer.u32(serializer, nonce)
    }
  }

  /// BCS `Option<u64>`: a single-byte tag (0 = none, 1 = some) followed by the little-endian value.
  private static func serializeOptionalU64(_ serializer: Serializer, _ value: UInt64?) throws {
    if let value {
      try Serializer.u8(serializer, UInt8(1))
      try Serializer.u64(serializer, value)
    } else {
      try Serializer.u8(serializer, UInt8(0))
    }
  }

  public static func deserialize(from deserializer: Deserializer) throws -> TransactionExpiration {
    let type = try Deserializer.u8(deserializer)

    switch type {
    case 0:
      return TransactionExpiration.none
    case 1:
      return TransactionExpiration.epoch(
        try Deserializer.u64(deserializer)
      )
    case 2:
      let minEpoch = try deserializeOptionalU64(deserializer)
      let maxEpoch = try deserializeOptionalU64(deserializer)
      let minTimestamp = try deserializeOptionalU64(deserializer)
      let maxTimestamp = try deserializeOptionalU64(deserializer)
      let chainLength = try deserializer.uleb128()
      var chain: [UInt8] = []
      for _ in 0..<chainLength { chain.append(try Deserializer.u8(deserializer)) }
      let nonce = try Deserializer.u32(deserializer)
      return TransactionExpiration.validDuring(
        minEpoch: minEpoch,
        maxEpoch: maxEpoch,
        minTimestamp: minTimestamp,
        maxTimestamp: maxTimestamp,
        chain: chain,
        nonce: nonce
      )
    default:
      throw SuiError.customError(message: "Unable to Deserialize")
    }
  }

  private static func deserializeOptionalU64(_ deserializer: Deserializer) throws -> UInt64? {
    switch try Deserializer.u8(deserializer) {
    case 0: return nil
    case 1: return try Deserializer.u64(deserializer)
    default: throw SuiError.customError(message: "Unable to Deserialize Option<u64>")
    }
  }
}
