//
//  JWTDecode.swift
//
//  Vendored from Auth0's JWTDecode.swift (MIT License).
//  https://github.com/auth0/JWTDecode.swift
//
//  Copyright (c) 2022 Auth0, Inc. <support@auth0.com> (http://auth0.com)
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
//  --------------------------------------------------------------------------
//  LeanSui vendor notes:
//    * The upstream package's three source files (JWT.swift, JWTDecode.swift,
//      JWTDecodeError.swift) are recombined here into one file, so it can be
//      vendored without maintaining a fork.
//    * `Claim.boolean` originally used CoreFoundation (`CFGetTypeID` /
//      `CFBooleanGetTypeID`) to distinguish a JSON boolean from a numeric
//      `NSNumber`. CoreFoundation is Darwin-only and breaks the Android
//      cross-compile, so it has been replaced with a Foundation-portable check
//      on `NSNumber.objCType` (which is `"c"` for a boolean-backed NSNumber).
//

import Foundation

// MARK: - JWT

/// A decoded JWT.
///
/// ## See Also
///
/// - [JWT.io](https://jwt.io)
public protocol JWT {

  /// Contents of the header part.
  var header: [String: Any] { get }

  /// Contents of the body part (claims).
  var body: [String: Any] { get }

  /// Signature part.
  var signature: String? { get }

  /// JWT string value.
  var string: String { get }

  /// Value of the `exp` claim, if available.
  var expiresAt: Date? { get }

  /// Value of the `iss` claim, if available.
  var issuer: String? { get }

  /// Value of the `sub` claim, if available.
  var subject: String? { get }

  /// Value of the `aud` claim, if available.
  var audience: [String]? { get }

  /// Value of the `iat` claim, if available.
  var issuedAt: Date? { get }

  /// Value of the `nbf` claim, if available.
  var notBefore: Date? { get }

  /// Value of the `jti` claim, if available.
  var identifier: String? { get }

  /// Checks if the JWT is currently expired using the `exp` claim. If the claim is not present the JWT will be
  /// deemed unexpired.
  var expired: Bool { get }

  /// Checks if the JWT will expire in the given time period (in seconds) using the `exp` claim.  If the claim is not
  /// present the JWT will be deemed to not expire.
  ///
  /// - Parameter seconds: Time period in seconds.
  /// - Returns: Whether the JWT will expire in the given time period or not.
  func expires(in seconds: Int) -> Bool

}

extension JWT {

  /// Returns a claim by its name.
  ///
  /// - Parameter name: Name of the claim in the JWT.
  /// - Returns: A ``Claim`` instance.
  public func claim(name: String) -> Claim {
    let value = self.body[name]
    return Claim(value: value)
  }

  /// Returns a claim by its name.
  ///
  /// - Parameter claim: Name of the claim in the JWT.
  /// - Returns: A ``Claim`` instance.
  public subscript(claim: String) -> Claim {
    return self.claim(name: claim)
  }

}

// MARK: - JWTDecodeError

/// A decoding error due to a malformed JWT.
public enum JWTDecodeError: LocalizedError, CustomDebugStringConvertible, Sendable {
  /// When either the header or body parts cannot be Base64URL-decoded.
  case invalidBase64URL(String)

  /// When either the decoded header or body is not a valid JSON object.
  case invalidJSON(String)

  /// When the JWT doesn't have the required amount of parts (header, body, and signature).
  case invalidPartCount(String, Int)

  /// Description of the error.
  ///
  /// - Important: You should avoid displaying the error description to the user, it's meant for **debugging** only.
  public var localizedDescription: String { return self.debugDescription }

  /// Description of the error.
  ///
  /// - Important: You should avoid displaying the error description to the user, it's meant for **debugging** only.
  public var errorDescription: String? { return self.debugDescription }

  /// Description of the error.
  ///
  /// - Important: You should avoid displaying the error description to the user, it's meant for **debugging** only.
  public var debugDescription: String {
    switch self {
    case .invalidJSON(let value):
      return "Failed to parse JSON from Base64URL value \(value)."
    case .invalidPartCount(let jwt, let parts):
      return "The JWT \(jwt) has \(parts) parts when it should have 3 parts."
    case .invalidBase64URL(let value):
      return "Failed to decode Base64URL value \(value)."
    }
  }
}

// MARK: - decode

/// Decodes a JWT into an object that holds the decoded body, along with the header and signature.
///
/// ```swift
/// let jwt = try decode(jwt: idToken)
/// ```
///
/// - Parameter jwt: JWT string value to decode.
/// - Throws: A ``JWTDecodeError`` error if the JWT cannot be decoded.
/// - Returns: A ``JWT`` value.
/// - Important: This method doesn't validate the JWT. Any well-formed JWT can be decoded from Base64URL.
func decode(jwt: String) throws -> JWT {  // internal: JWT/Claim/JSON (vendored JWTDecode) are not bridged; used only inside zkLogin.
  return try DecodedJWT(jwt: jwt)
}

struct DecodedJWT: JWT {

  let header: [String: Any]
  let body: [String: Any]
  let signature: String?
  let string: String

  init(jwt: String) throws {
    let parts = jwt.components(separatedBy: ".")
    guard parts.count == 3 else {
      throw JWTDecodeError.invalidPartCount(jwt, parts.count)
    }

    self.header = try decodeJWTPart(parts[0])
    self.body = try decodeJWTPart(parts[1])
    self.signature = parts[2]
    self.string = jwt
  }

  var expiresAt: Date? { return claim(name: "exp").date }
  var issuer: String? { return claim(name: "iss").string }
  var subject: String? { return claim(name: "sub").string }
  var audience: [String]? { return claim(name: "aud").array }
  var issuedAt: Date? { return claim(name: "iat").date }
  var notBefore: Date? { return claim(name: "nbf").date }
  var identifier: String? { return claim(name: "jti").string }

  var expired: Bool {
    return self.expires(before: Date())
  }

  func expires(in seconds: Int) -> Bool {
    let expireDate = Date(timeIntervalSinceNow: TimeInterval(seconds))
    return self.expires(before: expireDate)
  }

  func expires(before expireDate: Date) -> Bool {
    guard let date = self.expiresAt else {
      return false
    }

    return date.compare(expireDate) != ComparisonResult.orderedDescending
  }

}

// MARK: - Claim

/// A JWT claim.
public struct Claim {

  /// Raw claim value.
  let value: Any?

  /// Original claim value.
  public var rawValue: Any? {
    return self.value
  }

  /// Value of the claim as `String`.
  public var string: String? {
    return self.value as? String
  }

  /// Value of the claim as `Bool`.
  public var boolean: Bool? {
    // JSONSerialization deserializes JSON booleans into `NSNumber` values
    // backed by a boolean, the same as it does for integers/floats. To tell
    // a real JSON boolean apart from a numeric `NSNumber`, the upstream
    // package compared the value's CoreFoundation type ID to `CFBoolean`'s.
    // CoreFoundation is Darwin-only, so instead we inspect the `NSNumber`'s
    // Objective-C type encoding, which is `"c"` (a `char`) for a
    // boolean-backed NSNumber and a numeric code (`q`, `d`, …) otherwise.
    guard let number = self.value as? NSNumber else { return nil }
    guard String(cString: number.objCType) == "c" else { return nil }
    return number.boolValue
  }

  /// Value of the claim as `Double`.
  public var double: Double? {
    var double: Double?
    if let string = self.string {
      double = Double(string)
    } else if self.boolean == nil {
      double = self.value as? Double
    }
    return double
  }

  /// Value of the claim as `Int`.
  public var integer: Int? {
    var integer: Int?
    if let string = self.string {
      integer = Int(string)
    } else if let double = self.double {
      integer = Int(double)
    } else if self.boolean == nil {
      integer = self.value as? Int
    }
    return integer
  }

  /// Value of the claim as `Date`.
  public var date: Date? {
    guard let timestamp: TimeInterval = self.double else { return nil }
    return Date(timeIntervalSince1970: timestamp)
  }

  /// Value of the claim as `[String]`.
  public var array: [String]? {
    if let array = self.value as? [String] {
      return array
    }
    if let value = self.string {
      return [value]
    }
    return nil
  }

}

// MARK: - Base64URL / part decoding

private func base64UrlDecode(_ value: String) -> Data? {
  var base64 =
    value
    .replacingOccurrences(of: "-", with: "+")
    .replacingOccurrences(of: "_", with: "/")
  let length = Double(base64.lengthOfBytes(using: String.Encoding.utf8))
  let requiredLength = 4 * ceil(length / 4.0)
  let paddingLength = requiredLength - length
  if paddingLength > 0 {
    let padding = "".padding(toLength: Int(paddingLength), withPad: "=", startingAt: 0)
    base64 += padding
  }
  return Data(base64Encoded: base64, options: .ignoreUnknownCharacters)
}

private func decodeJWTPart(_ value: String) throws -> [String: Any] {
  guard let bodyData = base64UrlDecode(value) else {
    throw JWTDecodeError.invalidBase64URL(value)
  }

  guard let json = try? JSONSerialization.jsonObject(with: bodyData, options: []),
    let payload = json as? [String: Any]
  else {
    throw JWTDecodeError.invalidJSON(value)
  }

  return payload
}
