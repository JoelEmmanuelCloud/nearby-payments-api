import Combine
import Foundation

/// Drives the recipient field's edge-of-field state machine: idle → resolving → resolved ✓ / not-found
/// ✗. Addresses resolve instantly; SuiNS names debounce then hit the network.
@MainActor
final class RecipientViewModel: ObservableObject {
  enum State: Equatable {
    case idle
    case invalid
    case resolving
    case resolved(address: String, name: String?)
    case notFound
  }

  @Published
  private(set) var input = ""

  @Published
  private(set) var state: State = .idle

  private let service: RecipientService

  private var resolveTask: Task<Void, Never>?

  init(
    service: RecipientService = RecipientService(network: AppConstants.suiNetwork)
  ) {
    self.service = service
  }

  /// The address to send to, once a recipient resolves.
  var resolvedAddress: String? {
    if case .resolved(let address, _) = state { return address }
    return nil
  }

  /// Entry point from the text field: reparse, then resolve names after a debounce.
  func onInputChange(_ raw: String) {
    input = raw
    resolveTask?.cancel()

    switch RecipientInput.parse(raw) {
    case .empty:
      state = .idle
    case .invalid:
      state = .invalid
    case .address(let address):
      state = .resolved(address: address, name: nil)
    case .name(let name):
      state = .resolving
      resolveTask = Task { await resolve(name: name) }
    }
  }

  private func resolve(name: String) async {
    try? await Task.sleep(nanoseconds: UInt64(AppConstants.nameCheckDebounce * 1_000_000_000))
    guard !Task.isCancelled else { return }
    do {
      if let address = try await service.resolve(name: name) {
        guard !Task.isCancelled else { return }
        state = .resolved(address: address, name: name)
      } else {
        state = .notFound
      }
    } catch {
      guard !Task.isCancelled else { return }
      state = .notFound
    }
  }
}
