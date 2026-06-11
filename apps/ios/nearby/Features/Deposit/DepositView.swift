import SwiftUI
import UI

/// Placeholder deposit screen. The receive address + copy already live on the Profile tab, so this is
/// an intentional stub until the planned on-ramp / fiat deposit flow lands.
struct DepositView: View {
  var body: some View {
    VStack(spacing: 16) {
      Image(systemName: "arrow.down.circle.fill")
        .font(.system(size: 64))
        .foregroundColor(.secondary)

      MutedText("Coming soon")
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .navigationTitle("Deposit")
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    DepositView()
  }
}
