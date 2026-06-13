import AlertToast
import SwiftUI

/// Mounts the app-wide AlertToast presenter over `content`, driven by a `ToastController`. AlertToast's
/// HUD uses system material, so it follows the device light/dark theme automatically.
public struct ToastHost<Content: View>: View {
  @ObservedObject private var controller: ToastController

  private let content: Content

  public init(controller: ToastController, @ViewBuilder content: () -> Content) {
    self.controller = controller
    self.content = content()
  }

  public var body: some View {
    content
      .toast(isPresenting: $controller.isPresenting, duration: 2.5) {
        AlertToast(
          displayMode: .hud,
          type: alertType(for: controller.tone),
          title: controller.message)
      }
  }

  private func alertType(for tone: ToastTone) -> AlertToast.AlertType {
    switch tone {
    case .success: .complete(.green)
    case .warning: .systemImage("exclamationmark.triangle.fill", .orange)
    case .danger: .error(.red)
    case .neutral: .regular
    }
  }
}
