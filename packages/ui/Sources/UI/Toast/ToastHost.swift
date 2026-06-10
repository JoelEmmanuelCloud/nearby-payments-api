import SwiftUI

#if os(iOS)
  import Toasts
#endif

/// Mounts the app-wide toast presenter over `content`, driven by a `ToastController`. On iOS this uses
/// swiftui-toasts (window overlay, follows light/dark automatically); on macOS it's a passthrough
/// since the library is iOS-only.
public struct ToastHost<Content: View>: View {
  @ObservedObject private var controller: ToastController

  private let content: Content

  public init(controller: ToastController, @ViewBuilder content: () -> Content) {
    self.controller = controller
    self.content = content()
  }

  public var body: some View {
    #if os(iOS)
      ToastBridge(controller: controller, content: content)
        .installToast(position: .bottom)
    #else
      content
    #endif
  }
}

#if os(iOS)
  /// Lives under `installToast` so it can read `\.presentToast`, and forwards each `ToastController`
  /// event to it. The presenter is imperative, so we bridge the controller's published stream here.
  private struct ToastBridge<Content: View>: View {
    @ObservedObject var controller: ToastController
    @Environment(\.presentToast) private var presentToast

    let content: Content

    var body: some View {
      content
        .onReceive(controller.$pending.compactMap { $0 }) { event in
          presentToast(toastValue(for: event))
        }
    }

    private func toastValue(for event: ToastEvent) -> ToastValue {
      guard let symbol = symbolName(for: event.tone) else {
        return ToastValue(message: event.message)
      }
      return ToastValue(icon: Image(systemName: symbol), message: event.message)
    }

    private func symbolName(for tone: ToastTone) -> String? {
      switch tone {
      case .success: "checkmark.circle"
      case .warning: "exclamationmark.triangle.fill"
      case .danger: "xmark.circle"
      case .neutral: nil
      }
    }
  }
#endif
