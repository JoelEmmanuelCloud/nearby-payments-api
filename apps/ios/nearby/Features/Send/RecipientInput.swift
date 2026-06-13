import Foundation

/// Pure parsing + normalization of the recipient field. Accepts a raw `0x` address or a SuiNS name in
/// any of the forms `name`, `name.sui`, `sub.name`, `sub.name.sui` (a missing `.sui` is appended). No
/// network — fully unit-testable.
enum RecipientInput: Equatable {
  case empty
  /// A well-formed `0x…` address — usable directly, no resolution needed.
  case address(String)
  /// A normalized SuiNS name (always `.sui`-terminated) to resolve to an address.
  case name(String)
  /// Malformed — neither a valid address nor a valid name.
  case invalid

  static func parse(_ raw: String) -> RecipientInput {
    let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    guard !trimmed.isEmpty else { return .empty }

    if trimmed.hasPrefix("0x") {
      let hex = trimmed.dropFirst(2)
      let valid = !hex.isEmpty && hex.count <= 64 && hex.allSatisfy(\.isHexDigit)
      return valid ? .address(trimmed) : .invalid
    }

    let name = trimmed.hasSuffix(".sui") ? trimmed : trimmed + ".sui"
    return isValidName(name) ? .name(name) : .invalid
  }

  /// A `.sui`-terminated name of one or more `[a-z0-9-]` labels.
  private static func isValidName(_ name: String) -> Bool {
    let labels = name.split(separator: ".", omittingEmptySubsequences: false)
    guard labels.count >= 2, labels.last == "sui" else { return false }
    let nameLabels = labels.dropLast()
    guard !nameLabels.isEmpty else { return false }
    return nameLabels.allSatisfy { label in
      !label.isEmpty
        && label.allSatisfy { ($0.isLetter && $0.isASCII) || $0.isNumber || $0 == "-" }
    }
  }
}
