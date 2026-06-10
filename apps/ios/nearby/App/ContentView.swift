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
        case .home:
          HomeView(
            userName: viewModel.userName,
            store: viewModel.store,
            userId: viewModel.currentUserId,
            suiAddress: viewModel.currentSuiAddress,
            onNavigateToProfile: {
              viewModel.route = .profile(isSetupMode: false)
            },
            onSignOut: {
              viewModel.signOut()
            }
          )
        case .profile(let isSetupMode):
          ProfileView(
            viewModel: ProfileViewModel(
              identityManager: viewModel.identityManager,
              store: viewModel.store,
              toastController: viewModel.toastController,
              suiAddress: viewModel.currentSuiAddress,
              userId: viewModel.currentUserId,
              isSetupMode: isSetupMode,
              onFinish: {
                if isSetupMode {
                  viewModel.finishProfileSetup()
                } else {
                  viewModel.route = .home
                }
              }
            )
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
