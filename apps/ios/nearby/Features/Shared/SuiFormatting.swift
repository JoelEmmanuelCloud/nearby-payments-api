import Foundation
import LeanSuiApi

/// A `0xabcd…wxyz` short form of a Sui address for compact display.
func shortSuiAddress(_ address: String, leading: Int = 6, trailing: Int = 4) -> String {
  let body = address.hasPrefix("0x") ? String(address.dropFirst(2)) : address
  guard body.count > leading + trailing else { return address }
  return "0x\(body.prefix(leading))…\(body.suffix(trailing))"
}

/// Whether two Sui addresses are the same, tolerant of `0x` and leading-zero padding differences.
func isSameSuiAddress(_ a: String?, _ b: String?) -> Bool {
  func normalize(_ raw: String) -> String {
    var value = raw.lowercased()
    if value.hasPrefix("0x") { value.removeFirst(2) }
    let trimmed = String(value.drop { $0 == "0" })
    return trimmed.isEmpty ? "0" : trimmed
  }
  guard let a, let b else { return false }
  return normalize(a) == normalize(b)
}

/// A party label for display: "You" for the current user, the short address otherwise, "—" if absent.
func suiPartyLabel(_ address: String?, currentAddress: String?) -> String {
  guard let address else { return "—" }
  return isSameSuiAddress(address, currentAddress) ? "You" : shortSuiAddress(address)
}

/// The Suiscan explorer URL for a transaction digest on the app's network.
func suiExplorerURL(digest: String, network: SuiNetworkKind) -> URL? {
  let segment: String
  switch network {
  case .mainnet: segment = "mainnet"
  case .testnet: segment = "testnet"
  case .devnet: segment = "devnet"
  }
  return URL(string: "https://suiscan.xyz/\(segment)/tx/\(digest)")
}
