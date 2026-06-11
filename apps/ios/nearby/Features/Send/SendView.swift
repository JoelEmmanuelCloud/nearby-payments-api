import SwiftUI
import UI

/// Placeholder send screen. Replaced by the SuiNS-native send flow (amount → recipient → sign/execute)
/// in roadmap item #6; a stub for now so the Home "Send" action has a destination.
struct SendView: View {
  var body: some View {
    VStack(spacing: 16) {
      Image(systemName: "paperplane.circle.fill")
        .font(.system(size: 64))
        .foregroundColor(.secondary)

      MutedText("Coming soon")
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .navigationTitle("Send")
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    SendView()
  }
}
