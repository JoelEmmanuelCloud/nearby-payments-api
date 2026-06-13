import Combine
import Foundation
import UI

/// Owns the Home account-balance state and its 30s polling. Network IO lives in `BalanceService`;
/// this layer holds state, formats for display, and persists the visibility toggle.
///
/// The balance is shown in two parts: the **address balance** (spendable, the headline number) and a
/// **pending** balance held as coin objects, which the user moves into the address balance with an
/// explicit gasless consolidation (`ConsolidateService`).
@MainActor
final class HomeViewModel: ObservableObject {
  enum BalanceState {
    case loading
    case amount(Decimal)
  }

  /// The spendable (address) balance — the headline figure.
  @Published
  private(set) var balance: BalanceState = .loading

  /// The pending (coin-object) balance awaiting consolidation. `0` when there's nothing to move.
  @Published
  private(set) var pendingBalance: Decimal = 0

  @Published
  private(set) var isConsolidating = false

  @Published
  private(set) var isHidden: Bool

  private let service: BalanceService
  private let consolidateService: ConsolidateService?
  private let toastController: ToastController?
  private let suiAddress: String?
  private let store: AppSessionStore

  private var pollTask: Task<Void, Never>?
  private var observerTask: Task<Void, Never>?

  init(
    suiAddress: String?,
    store: AppSessionStore,
    service: BalanceService = BalanceService(
      network: AppConstants.suiNetwork, coinType: AppConstants.usdSuiCoinType),
    consolidateService: ConsolidateService? = nil,
    toastController: ToastController? = nil
  ) {
    self.suiAddress = suiAddress
    self.store = store
    self.service = service
    self.consolidateService = consolidateService
    self.toastController = toastController
    self.isHidden = store.balanceHidden()
    // Seed from the cached (spendable) balance so re-entering Home shows the last value immediately
    // (no skeleton); the poll below refreshes it silently.
    if let cached = store.lastUsdSuiBalance() {
      self.balance = .amount(cached)
    }
  }

  /// The spendable balance as a 2-decimal string (empty while loading).
  var formattedBalance: String {
    guard case .amount(let value) = balance else { return "" }
    return value.formatted(.number.precision(.fractionLength(2)))
  }

  /// The pending balance as a 2-decimal string.
  var formattedPendingBalance: String {
    pendingBalance.formatted(.number.precision(.fractionLength(2)))
  }

  /// Whether to surface the "move pending balance" call to action.
  var hasPendingBalance: Bool { pendingBalance > 0 }

  /// Whether consolidation can be triggered (a signer-backed service is wired and one isn't running).
  var canConsolidate: Bool { consolidateService != nil && !isConsolidating }

  /// Begins the silent 30s refresh loop and listens for account-change events. Idempotent.
  func start() {
    guard pollTask == nil else { return }
    pollTask = Task { [weak self] in
      while !Task.isCancelled {
        await self?.refresh()
        try? await Task.sleep(
          nanoseconds: UInt64(AppConstants.balanceRefreshInterval * 1_000_000_000))
      }
    }
    observerTask = Task { [weak self] in
      for await _ in AccountRefresh.events {
        await self?.refresh()
      }
    }
  }

  func stop() {
    pollTask?.cancel()
    pollTask = nil
    observerTask?.cancel()
    observerTask = nil
  }

  func toggleVisibility() {
    isHidden.toggle()
    store.setBalanceHidden(isHidden)
  }

  /// Moves the pending (coin-object) balance into the address balance. Gasless. Keeps the loading
  /// state until the refresh reflects the move (the pending strip leaves view first), then reports the
  /// outcome via a toast and broadcasts the change so Activity refreshes too.
  func consolidate() async {
    guard let consolidateService, !isConsolidating else { return }
    isConsolidating = true
    do {
      _ = try await consolidateService.consolidate()
      await refreshUntilPendingClears()
      AccountRefresh.post()
      toastController?.show("Moved to balance", tone: .success)
    } catch {
      let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
      toastController?.show(message, tone: .danger)
    }
    isConsolidating = false
  }

  /// Refreshes until the pending balance reads `0` (the consolidation consumed every coin) or the
  /// retry budget is spent — absorbing the brief indexer read-after-write lag after execution.
  private func refreshUntilPendingClears(maxAttempts: Int = 6) async {
    for attempt in 0..<maxAttempts {
      await refresh()
      if pendingBalance == 0 { return }
      if attempt < maxAttempts - 1 {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
      }
    }
  }

  private func refresh() async {
    guard let owner = suiAddress, !owner.isEmpty else { return }
    do {
      let breakdown = try await service.breakdown(owner: owner)
      balance = .amount(breakdown.addressBalance)
      pendingBalance = breakdown.coinBalance
      store.setLastUsdSuiBalance(breakdown.addressBalance)
    } catch {
      // Keep the last shown balance — stale beats a false 0.
    }
  }
}
