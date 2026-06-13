import Foundation

/// Pure logic for the predictive quick-select chips: as the user types, three scaled amounts are
/// suggested so a round figure is one tap away. No UI, fully unit-testable.
enum QuickSelect {
  /// Starter chips shown before anything positive is typed.
  static let defaults: [Decimal] = [10, 2000, 5000]

  /// Predictive chips are capped here — suggestions above this are dropped rather than shown.
  static let maxSuggestion: Decimal = 1_000_000

  /// Three quick-pick amounts for the typed `value`: ×10, ×100, ×1000 (so "5" → 50 / 500 / 5000), or
  /// the defaults when nothing positive is entered, dropping any that exceed `maxSuggestion`.
  static func suggestions(forValue value: Decimal) -> [Decimal] {
    let base = value > 0 ? [value * 10, value * 100, value * 1000] : defaults
    return base.filter { $0 <= maxSuggestion }
  }
}
