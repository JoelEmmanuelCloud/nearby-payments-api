import SwiftUI
import UI

struct HomeView: View {
  let userName: String
  let onSignOut: () -> Void

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 20) {
          VStack(alignment: .leading, spacing: 8) {
            Title("Home")
              .font(.title.weight(.semibold))

            MutedText("Signed in as \(userName).")
          }

          Card {
            VStack(alignment: .leading, spacing: 10) {
              Text("Account status")
                .font(.headline)

              MutedText(
                "Your session is ready. Wallet and zkLogin actions will appear here as the Sui package is wired in."
              )
            }
          }

          Card {
            VStack(alignment: .leading, spacing: 10) {
              Text("Next action")
                .font(.headline)

              MutedText(
                "Connect the lean Sui signer and transaction flow after authentication is stable on both platforms."
              )
            }
          }
        }
        .padding(24)
      }
      .navigationTitle("Nearby")
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button("Sign out") {
            onSignOut()
          }
        }
      }
    }
  }
}

#Preview {
  HomeView(userName: "Preview User", onSignOut: {})
}
