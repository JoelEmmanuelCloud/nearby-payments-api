//
//  ScalarConversion.swift
//  LeanSuiApi
//
//  The single, controlled place where Sui's string-encoded GraphQL scalars
//  (BigInt, UInt53, DateTime, Base64) are converted into real Swift domain
//  types. Because every numeric scalar arrives as a JSON *string*, no
//  precision is ever lost crossing the Apollo boundary.
//
//  NOTE: the generated schema declares `public typealias BigInt = String`
//  (Apollo references it as `LeanSuiApi.BigInt`). That shadows attaswift's
//  `BigInt` inside this module, so we use attaswift's `BigUInt` instead —
//  which is never shadowed and is the correct choice for on-chain magnitudes,
//  all of which are non-negative.
//

import BigInt
import Foundation

/// Conversion helpers for the GraphQL custom scalars.
enum Scalars {

  /// Parse a `BigInt` scalar string into an arbitrary-precision unsigned integer.
  public static func bigUInt(_ raw: String, field: String = "<bigint>") throws -> BigUInt {
    guard let value = BigUInt(raw) else {
      throw SuiAPIError.scalarDecoding(field: field, raw: raw)
    }
    return value
  }

  /// Parse a `UInt53` scalar (string-encoded, fits in `UInt64`).
  public static func uInt64(_ raw: String, field: String = "<uint53>") throws -> UInt64 {
    guard let value = UInt64(raw) else {
      throw SuiAPIError.scalarDecoding(field: field, raw: raw)
    }
    return value
  }

  /// Parse an ISO-8601 / RFC3339 `DateTime` scalar.
  public static func date(_ raw: String, field: String = "<datetime>") throws -> Date {
    let withFraction = ISO8601DateFormatter()
    withFraction.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    if let d = withFraction.date(from: raw) { return d }

    let plain = ISO8601DateFormatter()
    plain.formatOptions = [.withInternetDateTime]
    if let d = plain.date(from: raw) { return d }

    throw SuiAPIError.scalarDecoding(field: field, raw: raw)
  }

  /// Decode a `Base64` scalar into raw bytes.
  public static func base64(_ raw: String, field: String = "<base64>") throws -> [UInt8] {
    guard let data = Data(base64Encoded: raw) else {
      throw SuiAPIError.scalarDecoding(field: field, raw: raw)
    }
    return [UInt8](data)
  }
}

/// Unwrap an optional GraphQL field or throw a precise error.
@inlinable
func require<T>(_ value: T?, _ field: String) throws -> T {
  guard let value else { throw SuiAPIError.missingField(field) }
  return value
}
