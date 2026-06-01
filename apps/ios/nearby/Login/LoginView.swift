import AuthenticationServices
import SwiftUI
import UI

struct LoginView: View {
  @ObservedObject var viewModel: AppViewModel

  var body: some View {
    VStack(alignment: .leading, spacing: 24) {
      Spacer(minLength: 24)

      VStack(alignment: .leading, spacing: 10) {
        Title("Sign in")
          .font(.title.weight(.semibold))

        MutedText("Choose a provider to continue to your Nearby account.")
      }

      Card {
        VStack(alignment: .leading, spacing: 16) {
          MutedText("Account")

          SignInWithAppleButton(
            .continue,
            onRequest: viewModel.prepareAppleSignInRequest,
            onCompletion: viewModel.completeAppleSignIn
          )
          .signInWithAppleButtonStyle(.black)
          .frame(height: 48)
          .clipShape(Capsule())
          .disabled(viewModel.isSigningIn)

          GoogleSignInPillButton(isDisabled: viewModel.isSigningIn) {
            viewModel.signInWithGoogle()
          }

          if let statusMessage = viewModel.statusMessage {
            MutedText(statusMessage)
          }
        }
      }

      Spacer(minLength: 24)
    }
    .padding(24)
  }
}

#Preview {
  LoginView(viewModel: AppViewModel(store: AppSessionStore(defaults: .standard)))
}
