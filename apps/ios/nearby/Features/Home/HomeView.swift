import Gateway
import Identity
import SwiftUI
import UI

struct HomeView: View {
  let userName: String
  let store: AppSessionStore
  let userId: String
  let suiAddress: String?
  let currentProvider: OAuthProvider?
  let onSignOut: () -> Void

  @MainActor @StateObject private var balanceModel: HomeViewModel

  @State private var avatarUrl: String?

  @State private var suinsName: String?

  @State private var destination: HomeDestination?

  /// Pushed sub-routes reachable from the Home actions. `send` is a stub until roadmap #6.
  private enum HomeDestination: Hashable {
    case deposit, send
  }

  init(
    userName: String,
    store: AppSessionStore,
    userId: String,
    suiAddress: String?,
    currentProvider: OAuthProvider?,
    onSignOut: @escaping () -> Void
  ) {
    self.userName = userName
    self.store = store
    self.userId = userId
    self.suiAddress = suiAddress
    self.currentProvider = currentProvider
    self.onSignOut = onSignOut
    _balanceModel = StateObject(
      wrappedValue: HomeViewModel(suiAddress: suiAddress, store: store))
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 20) {
          MutedText("Signed in as \(suinsName ?? userName).")

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

          // Primary actions
          HStack(spacing: 12) {
            UIButton("Deposit") { destination = .deposit }
            SecondaryButton("Send") { destination = .send }
          }
        }
        .padding(24)
      }
      .navigationTitle("Home")
      .navigationDestination(item: $destination) { dest in
        switch dest {
        case .deposit: DepositView()
        case .send:
          SendAmountView(
            coinSymbol: AppConstants.balanceCoinSymbol,
            maxFractionDigits: AppConstants.balanceCoinDecimals,
            suiAddress: suiAddress,
            store: store,
            onNext: { _ in }  // 6c: navigate to the recipient step.
          )
        }
      }
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          HomeProviderIconView(currentProvider: currentProvider)
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
    currentProvider: .google,
    onSignOut: {}
  )
}
