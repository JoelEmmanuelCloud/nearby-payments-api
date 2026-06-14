import Combine
import Foundation
import LeanSuiApi
import UI

/// Owns the Activity feed: an append-only list of `SuiActivity` rows with cursor-based infinite
/// scroll. Network IO and formatting live in `ActivityService` / the shared package; this layer holds
/// state and the load/load-more transitions.
@MainActor
final class ActivityViewModel: ObservableObject {
  enum Phase {
    case loading
    case content
    case empty
    case error
  }

  @Published
  private(set) var phase: Phase = .loading

  @Published
  private(set) var items: [SuiActivity] = []

  @Published
  private(set) var isLoadingMore = false

  private let service: ActivityService
  private let address: String?
  private let store: AppSessionStore
  private let toastController: ToastController?

  private var cursor: String?

  private(set) var canLoadMore = false

  init(
    suiAddress: String?,
    store: AppSessionStore,
    service: ActivityService = ActivityService(
      network: AppConstants.suiNetwork, coinType: AppConstants.usdSuiCoinType),
    toastController: ToastController? = nil
  ) {
    self.address = suiAddress
    self.store = store
    self.service = service
    self.toastController = toastController
    // Seed from cache so re-entering Activity shows the last-known feed immediately (no skeleton);
    // `load` then refreshes it silently.
    if let suiAddress, !suiAddress.isEmpty {
      let cached = store.cachedActivity(for: suiAddress)
      if !cached.isEmpty {
        items = cached
        phase = .content
      }
    }
  }

  /// Initial load (and pull-to-refresh): resets to the newest page.
  func load() async {
    guard let address, !address.isEmpty else {
      phase = .empty
      return
    }
    if items.isEmpty { phase = .loading }
    cursor = nil
    let svc = service
    let addr = address
    do {
      let feed = try await withTimeout(seconds: AppConstants.networkTimeout) {
        try await svc.activity(address: addr, cursor: nil)
      }
      items = feed.items
      cursor = feed.nextCursor
      canLoadMore = feed.hasMore
      try await fillIfStarved()
      phase = items.isEmpty ? .empty : .content
      store.cacheActivity(items, for: address)
    } catch is TimeoutError {
      phase = items.isEmpty ? .error : .content
      toastController?.show("Couldn't refresh activity. Check your connection.", tone: .warning)
    } catch {
      phase = items.isEmpty ? .error : .content
    }
  }

  /// Appends the next older page; safe to call repeatedly (no-ops while already loading or exhausted).
  func loadMore() async {
    guard canLoadMore, !isLoadingMore, let address else { return }
    isLoadingMore = true
    defer { isLoadingMore = false }
    do {
      let feed = try await service.activity(address: address, cursor: cursor)
      items += feed.items
      cursor = feed.nextCursor
      canLoadMore = feed.hasMore
      phase = items.isEmpty ? (canLoadMore ? .loading : .empty) : .content
    } catch {
      // Keep what's shown; the row-level loader simply stops.
    }
  }

  /// Coin-filtering can yield an empty first page while older pages still hold matching rows. Pull a
  /// few more pages so the user doesn't see a false "no activity". Bounded to avoid runaway scans.
  private func fillIfStarved() async throws {
    var guardCount = 0
    while items.isEmpty, canLoadMore, guardCount < 5, let address {
      guardCount += 1
      let feed = try await service.activity(address: address, cursor: cursor)
      items += feed.items
      cursor = feed.nextCursor
      canLoadMore = feed.hasMore
    }
  }
}
