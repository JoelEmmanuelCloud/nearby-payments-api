import Foundation

/// The numeric-keypad input model for the send amount. A pure value type — keypad taps mutate it and
/// the view renders `display` — so the entry rules (single decimal point, bounded fraction length, no
/// leading-zero noise) are fully unit-testable without any UI.
struct AmountInput: Equatable {
  private(set) var text: String

  let maxFractionDigits: Int

  init(maxFractionDigits: Int) {
    self.text = ""
    self.maxFractionDigits = maxFractionDigits
  }

  /// What the big number shows — "0" while empty so the field is never blank.
  var display: String {
    text.isEmpty ? "0" : text
  }

  /// A strictly-positive amount has been entered (gates the "Next" action).
  var isValid: Bool {
    decimalValue > 0
  }

  var decimalValue: Decimal {
    Decimal(string: text) ?? 0
  }

  mutating func append(digit: Int) {
    guard (0...9).contains(digit) else { return }
    guard !fractionIsFull else { return }
    // Replace a lone leading "0" so we never produce "07" or "00".
    if text == "0" {
      text = String(digit)
    } else {
      text.append(String(digit))
    }
  }

  mutating func appendDecimal() {
    guard !text.contains(".") else { return }
    text = text.isEmpty ? "0." : text + "."
  }

  mutating func backspace() {
    guard !text.isEmpty else { return }
    text.removeLast()
  }

  mutating func clear() {
    text = ""
  }

  /// Replaces the entry with `value` (used by the quick-select chips). Formatted with "." and no
  /// grouping so it round-trips through `decimalValue` and the display unchanged.
  mutating func set(_ value: Decimal) {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.usesGroupingSeparator = false
    formatter.maximumFractionDigits = maxFractionDigits
    formatter.locale = Locale(identifier: "en_US_POSIX")
    text = formatter.string(from: value as NSDecimalNumber) ?? "0"
  }

  /// Whether the fraction already holds `maxFractionDigits` digits (further digits are ignored).
  private var fractionIsFull: Bool {
    guard let dot = text.firstIndex(of: ".") else { return false }
    return text.distance(from: text.index(after: dot), to: text.endIndex) >= maxFractionDigits
  }
}
