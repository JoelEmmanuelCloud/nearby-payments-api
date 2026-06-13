import Foundation

/// Pure validation of a Nearby leaf-name entry. A label is one or more `[a-z0-9-]` characters; a space
/// (or any other character) makes it invalid rather than being silently stripped. No network.
enum LeafNameInput: Equatable {
  case empty
  /// A normalized (trimmed, lowercased) valid label.
  case valid(String)
  case invalid

  static func parse(_ raw: String) -> LeafNameInput {
    let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return .empty }
    let lower = trimmed.lowercased()
    let valid = lower.allSatisfy { ($0.isLetter && $0.isASCII) || $0.isNumber || $0 == "-" }
    return valid ? .valid(lower) : .invalid
  }
}
