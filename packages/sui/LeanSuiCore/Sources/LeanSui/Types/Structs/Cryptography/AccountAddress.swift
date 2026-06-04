//
//  AccountAddress.swift
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

/// The Sui Blockchain Account Address
public struct AccountAddress: SuiBCSBridged, Equatable, CustomStringConvertible, Hashable {
  /// The address data itself
  public let address: Data

  /// The length of the data in bytes
  static let length: Int = 32

  public init(address: Data) throws {
    self.address = address

    if address.count != AccountAddress.length {
      throw SuiError.customError(
        message: "Invalid address length \(address.count), expected \(AccountAddress.length)")
    }
  }

  public var description: String {
    return self.hex()
  }

  /// Gives the hex value of the address
  /// - Returns: A String value represnting the address's hex value
  public func hex() -> String {
    return "0x\(address.hexEncodedString())"
  }

  /// Create an AccountAddress instance from a hexadecimal string.
  ///
  /// This function creates an AccountAddress instance from a hexadecimal string representing the account address. If the provided hexadecimal string starts with "0x",
  /// the function removes it before attempting to create the AccountAddress instance. If the length of the hexadecimal string is less than AccountAddress.length times 2,
  /// the function pads it with leading zeros to reach the required length.
  ///
  /// - Parameters:
  ///    - address: A string representing the hexadecimal account address to create the AccountAddress instance from.
  ///
  /// - Returns: An AccountAddress instance created from the provided hexadecimal string.
  ///
  /// - Throws: An error of type AptosError indicating that the provided hexadecimal string is invalid and cannot be converted to an AccountAddress instance.
  public static func fromHex(_ address: String) throws -> AccountAddress {
    var addr = address

    if address.hasPrefix("0x") {
      addr = String(address.dropFirst(2))
    }

    if addr.count < AccountAddress.length * 2 {
      let pad = String(repeating: "0", count: AccountAddress.length * 2 - addr.count)
      addr = pad + addr
    }

    guard let data = Data.fromHex(addr) else {
      throw SuiError.customError(message: "Invalid hex string")
    }
    return try AccountAddress(address: data)
  }

  public static func deserialize(from deserializer: Deserializer) throws -> AccountAddress {
    if deserializer.output()[0] == Self.length {
      let data = try Deserializer.toBytes(deserializer)
      return try AccountAddress(address: data)
    }
    return try AccountAddress(
      address: deserializer.fixedBytes(length: AccountAddress.length)
    )
  }

  public func serialize(_ serializer: Serializer) throws {
    serializer.fixedBytes(self.address)
  }
}
