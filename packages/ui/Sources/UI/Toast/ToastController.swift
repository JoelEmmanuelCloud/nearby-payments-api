import Combine

/// App-wide transient-message state. Callers invoke `show`; `ToastHost` renders it via AlertToast.
@MainActor
public final class ToastController: ObservableObject {
  @Published public var isPresenting = false

  public private(set) var message = ""
  public private(set) var tone: ToastTone = .danger

  public init() {}

  public func show(_ message: String, tone: ToastTone = .danger) {
    self.message = message
    self.tone = tone
    self.isPresenting = true
  }
}
