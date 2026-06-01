import SwiftUI

struct ContentView: View {
  @StateObject private var viewModel = AppViewModel()

  var body: some View {
    switch viewModel.route {
    case .onboarding:
      OnboardingView(viewModel: viewModel)
    case .login:
      LoginView(viewModel: viewModel)
    case .home:
      HomeView(viewModel: viewModel)
    }
  }
}

#Preview {
  ContentView()
}
