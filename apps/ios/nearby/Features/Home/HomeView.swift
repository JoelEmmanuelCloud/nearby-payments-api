import Identity
import SwiftUI
import UI

struct HomeView: View {
  let userName: String
  let store: AppSessionStore
  let userId: String
  let onNavigateToProfile: () -> Void
  let onSignOut: () -> Void

  @StateObject private var balanceModel: HomeViewModel

  @State private var avatarUrl: String?

  @State private var suinsName: String?

  init(
    userName: String,
    store: AppSessionStore,
    userId: String,
    suiAddress: String?,
    onNavigateToProfile: @escaping () -> Void,
    onSignOut: @escaping () -> Void
  ) {
    self.userName = userName
    self.store = store
    self.userId = userId
    self.onNavigateToProfile = onNavigateToProfile
    self.onSignOut = onSignOut
    _balanceModel = StateObject(
      wrappedValue: HomeViewModel(suiAddress: suiAddress, store: store))
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 20) {
          VStack(alignment: .leading, spacing: 8) {
            Title("Home")
              .font(.title.weight(.semibold))

            MutedText("Signed in as \(suinsName ?? userName).")
          }

          // Account balance
          Card {
            VStack(alignment: .leading, spacing: 12) {
              HStack {
                Text("Account balance")
                  .font(.headline)

                Spacer()

                Button {
                  balanceModel.toggleVisibility()
                } label: {
                  Image(systemName: balanceModel.isHidden ? "eye.slash" : "eye")
                    .foregroundColor(.secondary)
                }
              }

              HStack(spacing: 10) {
                Image("SuiDropletBlue")
                  .resizable()
                  .scaledToFit()
                  .frame(width: 28, height: 28)

                if balanceModel.isHidden {
                  Text("••••")
                    .font(.title2.weight(.semibold))
                } else {
                  switch balanceModel.balance {
                  case .loading:
                    Skeleton()
                      .frame(width: 120, height: 26)
                  case .amount:
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                      Text(balanceModel.formattedBalance)
                        .font(.title2.weight(.semibold))
                      Text("USDsui")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }
                  }
                }
              }
            }
          }
        }
        .padding(24)
      }
      .navigationTitle("Nearby")
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button(action: onNavigateToProfile) {
            Avatar(size: 32) {
              if let urlString = avatarUrl, let url = URL(string: urlString) {
                RemoteImage(url: url)
              }
            }
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
        balanceModel.start()
      }
      .onDisappear {
        balanceModel.stop()
      }
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
    suiAddress: nil,
    onNavigateToProfile: {},
    onSignOut: {}
  )
}
