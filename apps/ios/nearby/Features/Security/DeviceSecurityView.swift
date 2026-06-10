import SwiftUI
import UI

/// SwiftUI View displayed when system-level device security (passcode, Face ID, or Touch ID)
/// is not configured or enabled on the user's device.
struct DeviceSecurityView: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 24) {
      Spacer(minLength: 24)

      VStack(alignment: .leading, spacing: 10) {
        Title("Set up device security")
          .font(.title.weight(.semibold))

        MutedText(
          "Nearby needs Face ID, Touch ID, or a device passcode before sign-in so your secure key can authorize wallet actions."
        )
      }

      Card {
        VStack(alignment: .leading, spacing: 16) {
          MutedText("Device security")
          MutedText("Set up Face ID, Touch ID, or a passcode in Settings, then return to Nearby.")

          UIButton("Open Settings") {
            openSettings()
          }
        }
      }

      Spacer(minLength: 24)
    }
    .padding(24)
  }

  private func openSettings() {
    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
    UIApplication.shared.open(url)
  }
}

#Preview {
  DeviceSecurityView()
}
