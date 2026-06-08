import AuthenticationServices
import SwiftUI
import UI

struct LoginView: View {
  @ObservedObject var viewModel: LoginViewModel
  let onSignInSuccess: (String) -> Void

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
            onCompletion: { result in
              viewModel.completeAppleSignIn(result, onSuccess: onSignInSuccess)
            }
          )
          .signInWithAppleButtonStyle(.black)
          .frame(height: 48)
          .clipShape(Capsule())
          .disabled(viewModel.isSigningIn || !viewModel.isReadyToSignIn)

          GoogleSignInPillButton(
            isDisabled: viewModel.isSigningIn || !viewModel.isReadyToSignIn
          ) {
            viewModel.signInWithGoogle(onSuccess: onSignInSuccess)
          }

          if let statusMessage = viewModel.statusMessage {
            MutedText(statusMessage)
          }
        }
      }

      Spacer(minLength: 24)
    }
    .padding(24)
    .task {
      await viewModel.prepareZkNonce()
    }
  }
}
