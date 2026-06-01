import Crypto
import Foundation

extension Data {
  func base64urlEncodedString() -> String {
    return self.base64EncodedString()
      .replacingOccurrences(of: "+", with: "-")
      .replacingOccurrences(of: "/", with: "_")
      .replacingOccurrences(of: "=", with: "")
  }
}

public struct PKCE {
  public static func generateCodeVerifier() -> String {
    let key = SymmetricKey(size: SymmetricKeySize(bitCount: 32 * 8))
    let bytes = key.withUnsafeBytes { Array($0) }
    return Data(bytes).base64urlEncodedString()
  }

  public static func generateCodeChallenge(verifier: String) -> String {
    return hash(verifier).base64urlEncodedString()
  }

  public static func hash(_ input: String) -> Data {
    Data(SHA256.hash(data: Data(input.utf8)))
  }
}
