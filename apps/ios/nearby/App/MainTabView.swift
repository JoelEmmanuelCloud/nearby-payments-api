import Auth
import Gateway
import HSM
import Identity
import LeanSui
import LeanSuiApi
import Storage
import SwiftUI
import UI

struct MainTabView: View {
  let userName: String
  let store: AppSessionStore
  let userId: String
  let suiAddress: String?
  let currentProvider: OAuthProvider?
  let signerProvider: SignerProvider
  let toastController: ToastController
  let onSignOut: () -> Void

  /// One shared profile model for the whole tab shell: the Profile screen edits it, and the "You" tab
  /// icon observes its `avatarUrl`. Hoisting it here (vs. a throwaway built in `body`) is what lets a
  /// profile write reach the tab icon directly — no app-wide notification needed.
  @StateObject private var profileViewModel: ProfileViewModel

  @State private var selectedTab: Tab = .home
  @State private var avatarImage: UIImage? = nil

  enum Tab: Hashable {
    case home, activity, profile
  }

  init(
    userName: String,
    store: AppSessionStore,
    userId: String,
    suiAddress: String?,
    currentProvider: OAuthProvider?,
    identityManager: IdentityManager,
    toastController: ToastController,
    signerProvider: @escaping SignerProvider,
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
    _profileViewModel = StateObject(
      wrappedValue: ProfileViewModel(
        identityManager: identityManager,
        store: store,
        toastController: toastController,
        suiAddress: suiAddress,
        userId: userId
      )
    )
  }

  var body: some View {
    TabView(selection: $selectedTab) {
      HomeView(
        userName: userName,
        store: store,
        userId: userId,
        suiAddress: suiAddress,
        currentProvider: currentProvider,
        signerProvider: signerProvider,
        toastController: toastController,
        onSignOut: onSignOut
      )
      .tabItem {
        Label {
          Text("Space")
        } icon: {
          Image("Home")
        }
      }
      .tag(Tab.home)

      ActivityView(suiAddress: suiAddress, store: store, toastController: toastController)
        .tabItem {
          Label {
            Text("Activity")
          } icon: {
            Image("Receipt")
          }
        }
        .tag(Tab.activity)

      ProfileView(viewModel: profileViewModel)
        .tabItem {
          Label {
            Text("You")
          } icon: {
            if let avatarImage {
              Image(uiImage: avatarImage)
                .renderingMode(.original)
            } else {
              Image(systemName: "person")
            }
          }
        }
        .tag(Tab.profile)
    }
    .onAppear {
      loadAvatar()
    }
    .onChange(of: profileViewModel.avatarUrl) { _, _ in
      loadAvatar()
    }
  }

  /// Resolve the shared model's avatar URL into a circular `UIImage` for the tab item (the tab bar
  /// needs a concrete `UIImage`, so the async `RemoteImage` view can't be reused here).
  private func loadAvatar() {
    guard let avatarUrlString = profileViewModel.avatarUrl,
      let url = URL(string: avatarUrlString)
    else {
      self.avatarImage = nil
      return
    }
    Task {
      if let img = await ImageLoader.shared.image(for: url) {
        // .alwaysOriginal on the UIImage itself — the tab bar template-renders its icons otherwise,
        // and SwiftUI's .renderingMode(.original) doesn't survive the Label → UITabBarItem bridge.
        self.avatarImage = img.circularImage(size: 26)?.withRenderingMode(.alwaysOriginal)
      }
    }
  }
}

extension UIImage {
  func circularImage(size: CGFloat) -> UIImage? {
    let minEdge = min(self.size.width, self.size.height)
    let cropRect = CGRect(
      x: (self.size.width - minEdge) / 2,
      y: (self.size.height - minEdge) / 2,
      width: minEdge,
      height: minEdge
    )

    guard let cgImage = self.cgImage?.cropping(to: cropRect) else { return nil }

    let targetSize = CGSize(width: size, height: size)
    UIGraphicsBeginImageContextWithOptions(targetSize, false, 0.0)

    let path = UIBezierPath(ovalIn: CGRect(origin: .zero, size: targetSize))
    path.addClip()

    UIImage(cgImage: cgImage, scale: self.scale, orientation: self.imageOrientation)
      .draw(in: CGRect(origin: .zero, size: targetSize))

    let result = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return result
  }
}

#Preview {
  MainTabView(
    userName: "Preview User",
    store: AppSessionStore(),
    userId: "preview",
    suiAddress: nil,
    currentProvider: .google,
    identityManager: IdentityManager(
      gateway: try! APIGateway(baseURLString: "https://example.com", apiVersion: "v1"),
      nsResolver: GraphQLSuiProvider(network: SuiNetwork(kind: .mainnet)),
      sessionManager: SessionManager(
        storage: KeychainProvider(),
        hsm: SecureEnclaveHSM(),
        gateway: try! APIGateway(baseURLString: "https://example.com", apiVersion: "v1")
      )
    ),
    toastController: ToastController(),
    signerProvider: { try await ZkLoginService.preview.signer() },
    onSignOut: {}
  )
}
