import SwiftUI

struct OnboardingProgressView: View {
  let currentIndex: Int
  let count: Int

  var body: some View {
    HStack(spacing: 8) {
      ForEach(0..<count, id: \.self) { index in
        Capsule()
          .fill(index <= currentIndex ? Color.primary : Color.secondary.opacity(0.25))
          .frame(height: 4)
      }
    }
    .accessibilityLabel("Onboarding step \(currentIndex + 1) of \(count)")
  }
}

#Preview {
  OnboardingProgressView(currentIndex: 1, count: 3)
    .padding()
}
