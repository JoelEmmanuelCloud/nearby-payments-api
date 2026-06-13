import Combine
import Foundation

/// Owns the send-amount entry: the keypad mutates an `AmountInput`, and the typed amount is validated
/// against the available balance. The balance is seeded from cache (instant) and refreshed once when
/// the screen appears, so validation is live without re-fetching on every keystroke.
@MainActor
final class SendAmountViewModel: ObservableObject {
  @Published
  private(set) var input: AmountInput

  /// The owner's spendable balance of the send coin. `nil` until known — while unknown we don't block,
  /// deferring the check rather than showing a false "insufficient".
  @Published
  private(set) var availableBalance: Decimal?

  let coinSymbol: String

  private let suiAddress: String?
  private let store: AppSessionStore
  private let service: BalanceService

  init(
    coinSymbol: String,
    maxFractionDigits: Int,
    suiAddress: String?,
    store: AppSessionStore,
    service: BalanceService = BalanceService(
      network: AppConstants.suiNetwork, coinType: AppConstants.usdSuiCoinType)
  ) {
    self.coinSymbol = coinSymbol
    self.input = AmountInput(maxFractionDigits: maxFractionDigits)
    self.suiAddress = suiAddress
    self.store = store
    self.service = service
    self.availableBalance = store.lastUsdSuiBalance()
  }

  /// True once a positive amount strictly exceeds the known balance.
  var exceedsBalance: Bool {
    guard let availableBalance else { return false }
    return input.decimalValue > availableBalance
  }

  /// Whether the entry can advance: a positive amount that fits the balance.
  var canContinue: Bool {
    input.isValid && !exceedsBalance
  }

  /// The predictive quick-pick amounts for the current entry.
  var suggestions: [Decimal] {
    QuickSelect.suggestions(forValue: input.decimalValue)
  }

  /// Whether a suggestion fits the known balance (chips above it are disabled).
  func isWithinBalance(_ value: Decimal) -> Bool {
    guard let availableBalance else { return true }
    return value <= availableBalance
  }

  /// Fills the entry from a tapped quick-select chip.
  func select(_ value: Decimal) {
    input.set(value)
  }

  func handle(_ key: KeypadKey) {
    switch key {
    case .digit(let value):
      input.append(digit: value)
    case .decimal:
      input.appendDecimal()
    case .backspace:
      input.backspace()
    }
  }

  /// One-shot freshness fetch on screen appear; falls back to the seeded cache value on failure.
  func refreshBalance() async {
    guard let suiAddress, !suiAddress.isEmpty else { return }
    do {
      let amount = try await service.usdSuiBalance(owner: suiAddress)
      availableBalance = amount
      store.setLastUsdSuiBalance(amount)
    } catch {
      // Keep the seeded value — stale beats blocking the user on a transient failure.
    }
  }
}
