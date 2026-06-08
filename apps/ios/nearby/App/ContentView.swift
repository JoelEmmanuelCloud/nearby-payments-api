import SwiftUI

struct ContentView: View {
  @StateObject private var viewModel = AppViewModel()

  var body: some View {
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
            zkLoginService: viewModel.zkLoginService
          ),
          onSignInSuccess: { userName in
            viewModel.handleSignInSuccess(userName: userName)
          }
        )
      case .home:
        HomeView(
          userName: viewModel.userName,
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

#Preview {
  ContentView()
}
