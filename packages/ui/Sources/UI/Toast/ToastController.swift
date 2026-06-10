import Combine

/// A single transient message to surface. `ToastController.show` produces one; `ToastHost` forwards
/// it to the toast backend.
public struct ToastEvent {
  public let message: String
  public let tone: ToastTone
}

/// App-wide transient-message bus. Callers invoke `show`; `ToastHost` observes `pending` and presents
/// it (via swiftui-toasts on iOS). Decouples message producers from the presenter.
@MainActor
public final class ToastController: ObservableObject {
  @Published public private(set) var pending: ToastEvent?

  public init() {}

  public func show(_ message: String, tone: ToastTone = .danger) {
    pending = ToastEvent(message: message, tone: tone)
  }
}
