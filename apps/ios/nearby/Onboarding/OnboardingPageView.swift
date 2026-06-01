import SwiftUI
import UI

struct OnboardingPageView: View {
  let page: OnboardingPage

  var body: some View {
    VStack(alignment: .leading, spacing: 14) {
      Title(page.title)
        .font(.title.weight(.semibold))

      MutedText(page.message)
        .font(.body)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

#Preview {
  OnboardingPageView(
    page: OnboardingPage(
      title: "Keep nearby access simple",
      message: "Use one account flow for wallets, device trust, and session recovery."
    )
  )
  .padding()
}
