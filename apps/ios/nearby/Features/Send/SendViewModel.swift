import Combine
import Foundation

/// Drives the send execution that runs from the recipient screen (#6d): an idle → sending →
/// success / failure state machine around `SendService`. The amount is fixed for the screen's
/// lifetime; the recipient is supplied at send time (once it has resolved).
@MainActor
final class SendViewModel: ObservableObject {
  enum State: Equatable {
    case idle
    case sending
    case success(digest: String)
    case failure(message: String)
  }

  @Published private(set) var state: State = .idle

  let amount: Decimal
  let coinSymbol: String

  private let service: SendService

  init(amount: Decimal, coinSymbol: String, service: SendService) {
    self.amount = amount
    self.coinSymbol = coinSymbol
    self.service = service
  }

  var isSending: Bool {
    if case .sending = state { return true }
    return false
  }

  /// Executes the gasless send to `recipient`. On success, broadcasts the account change so the
  /// balance- and activity-backed screens refresh before the user returns to them.
  func send(to recipient: String) async {
    guard state != .sending else { return }
    state = .sending
    do {
      let digest = try await service.send(amount: amount, recipient: recipient)
      AccountRefresh.post()
      state = .success(digest: digest)
    } catch {
      let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
      state = .failure(message: message)
    }
  }
}
