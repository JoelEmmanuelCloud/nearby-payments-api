import Gateway
import Identity
import LeanSui
import SwiftUI
import UI

struct HomeView: View {
  let userName: String
  let store: AppSessionStore
  let userId: String
  let suiAddress: String?
  let currentProvider: OAuthProvider?
  let signerProvider: SignerProvider
  let toastController: ToastController
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
    signerProvider: @escaping SignerProvider,
    toastController: ToastController,
    onSignOut: @escaping () -> Void
  ) {
    self.userName = userName
    self.store = store
    self.userId = userId
    self.suiAddress = suiAddress
    self.currentProvider = currentProvider
    self.signerProvider = signerProvider
    self.toastController = toastController
    self.onSignOut = onSignOut
    _balanceModel = StateObject(
      wrappedValue: HomeViewModel(
        suiAddress: suiAddress,
        store: store,
        consolidateService: ConsolidateService(signerProvider: signerProvider),
        toastController: toastController))
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

              // Pending (coin-object) balance: a thin call-to-action shown only when there's value
              // to move into the spendable address balance. Tapping runs the gasless consolidation.
              if !balanceModel.isHidden && balanceModel.hasPendingBalance {
                pendingBalanceStrip
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
            signerProvider: signerProvider,
            onFinish: { destination = nil }
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

  /// The thin "pending balance" call to action at the bottom of the balance card. Surfaces value held
  /// as coin objects and moves it into the spendable address balance with one gasless transaction.
  @ViewBuilder
  private var pendingBalanceStrip: some View {
    Button {
      Task { await balanceModel.consolidate() }
    } label: {
      HStack(spacing: 8) {
        if balanceModel.isConsolidating {
          ProgressView().controlSize(.mini)
          Text("Moving to balance…")
            .foregroundColor(.secondary)
        } else {
          Image(systemName: "tray.and.arrow.down.fill")
            .foregroundColor(.accentColor)
          Text("\(balanceModel.formattedPendingBalance) USDsui pending")
            .foregroundColor(.primary)
          Spacer(minLength: 8)
          Text("Move to balance")
            .fontWeight(.semibold)
            .foregroundColor(.accentColor)
        }
      }
      .font(.footnote)
      .padding(.vertical, 10)
      .padding(.horizontal, 12)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(Color.accentColor.opacity(0.12))
      .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    .buttonStyle(.plain)
    .disabled(!balanceModel.canConsolidate)
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
    signerProvider: { try await ZkLoginService.preview.signer() },
    toastController: ToastController(),
    onSignOut: {}
  )
}
