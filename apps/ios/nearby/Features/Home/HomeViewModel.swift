import Combine
import Foundation

/// Owns the Home account-balance state and its 30s polling. Network IO lives in `BalanceService`;
/// this layer holds state, formats for display, and persists the visibility toggle.
@MainActor
final class HomeViewModel: ObservableObject {
  enum BalanceState {
    case loading
    case amount(Decimal)
  }

  @Published
  private(set) var balance: BalanceState = .loading

  @Published
  private(set) var isHidden: Bool

  private let service: BalanceService
  private let suiAddress: String?
  private let store: AppSessionStore

  private var pollTask: Task<Void, Never>?

  init(
    suiAddress: String?,
    store: AppSessionStore,
    service: BalanceService = BalanceService()
  ) {
    self.suiAddress = suiAddress
    self.store = store
    self.service = service
    self.isHidden = store.balanceHidden()
    // Seed from the cached balance so re-entering Home shows the last value immediately (no skeleton);
    // the poll below refreshes it silently.
    if let cached = store.lastUsdSuiBalance() {
      self.balance = .amount(cached)
    }
  }

  /// The balance as a 2-decimal string (empty while loading).
  var formattedBalance: String {
    guard case .amount(let value) = balance else { return "" }
    return value.formatted(.number.precision(.fractionLength(2)))
  }

  /// Begins the silent 30s refresh loop. Idempotent.
  func start() {
    guard pollTask == nil else { return }
    pollTask = Task { [weak self] in
      while !Task.isCancelled {
        await self?.refresh()
        try? await Task.sleep(
          nanoseconds: UInt64(AppConstants.balanceRefreshInterval * 1_000_000_000))
      }
    }
  }

  func stop() {
    pollTask?.cancel()
    pollTask = nil
  }

  func toggleVisibility() {
    isHidden.toggle()
    store.setBalanceHidden(isHidden)
  }

  private func refresh() async {
    guard let owner = suiAddress, !owner.isEmpty else { return }
    do {
      let amount = try await service.usdSuiBalance(owner: owner)
      balance = .amount(amount)
      store.setLastUsdSuiBalance(amount)
    } catch {
      // Keep the last shown balance — stale beats a false 0.
    }
  }
}
