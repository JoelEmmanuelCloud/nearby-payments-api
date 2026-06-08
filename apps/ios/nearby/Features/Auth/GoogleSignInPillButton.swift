import SwiftUI

struct GoogleSignInPillButton: View {
  let isDisabled: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack(spacing: 12) {
        Image("GoogleG")
          .resizable()
          .frame(width: 18, height: 18)

        Text("Continue with Google")
          .font(.system(size: 15, weight: .medium))
          .foregroundStyle(Color(red: 0.12, green: 0.12, blue: 0.12))
      }
      .frame(maxWidth: .infinity, minHeight: 48)
      .background(Color.white)
      .overlay {
        Capsule()
          .stroke(Color(red: 0.45, green: 0.47, blue: 0.46), lineWidth: 1)
      }
      .clipShape(Capsule())
      .opacity(isDisabled ? 0.55 : 1)
    }
    .buttonStyle(.plain)
    .disabled(isDisabled)
    .accessibilityLabel("Continue with Google")
  }
}

#Preview {
  VStack(spacing: 16) {
    GoogleSignInPillButton(isDisabled: false) {}
    GoogleSignInPillButton(isDisabled: true) {}
  }
  .padding()
}
