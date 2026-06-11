import SwiftUI
import UI

struct ActivityView: View {
  var body: some View {
    NavigationStack {
      VStack(spacing: 16) {
        Image(systemName: "list.bullet.circle.fill")
          .font(.system(size: 64))
          .foregroundColor(.secondary)

        MutedText("Coming soon")
      }
      .navigationTitle("Activity")
    }
  }
}

#Preview {
  ActivityView()
}
