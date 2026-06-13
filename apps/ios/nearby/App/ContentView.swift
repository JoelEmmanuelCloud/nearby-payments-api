import SwiftUI
import UI

struct ContentView: View {
  @StateObject private var viewModel = AppViewModel()

  var body: some View {
    ToastHost(controller: viewModel.toastController) {
      Group {
        switch viewModel.route {
        case .loading:
          ProgressView()
        case .onboarding:
          OnboardingView {
            viewModel.finishOnboarding()
          }
        case .deviceSecurity:
          DeviceSecurityView()
        case .login:
          LoginView(
            viewModel: LoginViewModel(
              authManager: viewModel.authManager,
              zkLoginService: viewModel.zkLoginService,
              toastController: viewModel.toastController
            ),
            onSignInSuccess: { userName in
              viewModel.handleSignInSuccess(userName: userName)
            }
          )
        case .main:
          MainTabView(
            userName: viewModel.userName,
            store: viewModel.store,
            userId: viewModel.currentUserId,
            suiAddress: viewModel.currentSuiAddress,
            currentProvider: viewModel.currentProvider,
            identityManager: viewModel.identityManager,
            toastController: viewModel.toastController,
            signerProvider: { try await viewModel.reauthenticatedSigner() },
            onSignOut: {
              viewModel.signOut()
            }
          )
        }
      }
      .onReceive(NotificationCenter.default.publisher(for: .nearbyAppDidBecomeActive)) { _ in
        viewModel.refreshDeviceSecurityGate()
      }
    }
  }

}

#Preview {
  ContentView()
}
