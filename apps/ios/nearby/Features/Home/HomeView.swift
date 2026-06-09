import Identity
import SwiftCache
import SwiftUI
import UI

struct HomeView: View {
  let userName: String
  let store: AppSessionStore
  let userId: String
  let onNavigateToProfile: () -> Void
  let onSignOut: () -> Void

  @State private var avatarUrl: String?
  @State private var suinsName: String?

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 20) {
          VStack(alignment: .leading, spacing: 8) {
            Title("Home")
              .font(.title.weight(.semibold))

            MutedText("Signed in as \(suinsName ?? userName).")
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
        ToolbarItem(placement: .topBarLeading) {
          Button(action: onNavigateToProfile) {
            avatarButton
              .frame(width: 32, height: 32)
              .clipShape(Circle())
          }
        }
        ToolbarItem(placement: .topBarTrailing) {
          Button("Sign out") {
            onSignOut()
          }
        }
      }
      .onAppear {
        loadCachedIdentity()
      }
    }
  }

  @ViewBuilder private var avatarButton: some View {
    if let urlString = avatarUrl, let url = URL(string: urlString) {
      // Loaded and memory+disk-cached by SwiftCache, keyed by URL.
      CachedImage(url: url) {
        Image(systemName: "person.crop.circle").resizable()
      }
      .scaledToFill()
    } else {
      Image(systemName: "person.crop.circle").resizable()
    }
  }

  private func loadCachedIdentity() {
    guard let cached = store.cachedProfile(userId: userId) else { return }
    self.suinsName = cached.suinsName
    self.avatarUrl = cached.avatarUrl
  }
}

#Preview {
  HomeView(
    userName: "Preview User",
    store: AppSessionStore(),
    userId: "preview",
    onNavigateToProfile: {},
    onSignOut: {}
  )
}
