import Crypto
import Foundation

extension Data {
  /// Encodes data into a base64url-encoded string, which is safe for URLs and filenames.
  /// It replaces '+' with '-', '/' with '_', and strips trailing '=' padding characters.
  ///
  /// - Returns: A base64url-encoded string representation of the data.
  func base64urlEncodedString() -> String {
    return self.base64EncodedString()
      .replacingOccurrences(of: "+", with: "-")
      .replacingOccurrences(of: "/", with: "_")
      .replacingOccurrences(of: "=", with: "")
  }
}

/// Helper struct for generating Proof Key for Code Exchange (PKCE) parameters.
/// PKCE is used to secure OAuth 2.0 flows on mobile/desktop clients.
public struct PKCE {
  /// Generates a cryptographically secure random code verifier.
  ///
  /// - Returns: A base64url-encoded 32-byte string.
  public static func generateCodeVerifier() -> String {
    var rng = SystemRandomNumberGenerator()
    let bytes = (0..<32).map { _ in UInt8.random(in: 0...255, using: &rng) }
    return Data(bytes).base64urlEncodedString()
  }

  /// Derives a code challenge from the given verifier using SHA-256 base64url encoding.
  ///
  /// - Parameter verifier: The PKCE code verifier.
  /// - Returns: The derived PKCE code challenge.
  public static func generateCodeChallenge(verifier: String) -> String {
    return hash(verifier).base64urlEncodedString()
  }

  /// Hashes a string using SHA-256 and returns the digest as a base64url-encoded string.
  ///
  /// - Parameter input: The string input to hash.
  /// - Returns: The base64url-encoded SHA-256 digest.
  public static func hashBase64URL(_ input: String) -> String {
    hash(input).base64urlEncodedString()
  }

  /// Hashes a string using SHA-256.
  ///
  /// - Parameter input: The string input to hash.
  /// - Returns: The SHA-256 digest wrapped in a `Data` object.
  static func hash(_ input: String) -> Data {
    Data(SHA256.hash(data: Data(input.utf8)))
  }
}
