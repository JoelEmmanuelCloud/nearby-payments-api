import SwiftUI
import UI

/// The terminal screen of the send flow (#6e): the outcome of a gasless transfer — success with the
/// on-chain digest, or a failure with its message. Reached only after the transaction settles, so it
/// never shows a loading state. `onDone` dismisses the whole flow; `onRetry` returns to the recipient
/// screen to try again.
struct SendResultView: View {
  enum Outcome: Hashable {
    case success(digest: String)
    case failure(message: String)
  }

  let outcome: Outcome
  let amount: Decimal
  let coinSymbol: String
  let recipient: String
  let onDone: () -> Void
  let onRetry: () -> Void

  var body: some View {
    VStack(spacing: 24) {
      Spacer()

      switch outcome {
      case .success(let digest):
        icon("checkmark.circle.fill", tint: .green)
        Text("Sent")
          .font(.title2.weight(.semibold))
        Text(
          "\(amount.formatted(.number.grouping(.automatic))) \(coinSymbol) to \(shortSuiAddress(recipient))"
        )
        .font(.subheadline)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)
        Text(shortSuiAddress(digest))
          .font(.footnote.monospaced())
          .foregroundColor(.secondary)
          .textSelection(.enabled)

      case .failure(let message):
        icon("exclamationmark.triangle.fill", tint: .red)
        Text("Couldn't send")
          .font(.title2.weight(.semibold))
        Text(message)
          .font(.subheadline)
          .foregroundColor(.secondary)
          .multilineTextAlignment(.center)
      }

      Spacer()

      action
    }
    .padding(24)
    .navigationTitle("")
    .navigationBarBackButtonHidden(true)
  }

  @ViewBuilder
  private var action: some View {
    switch outcome {
    case .success:
      UIButton("Done") { onDone() }
    case .failure:
      UIButton("Try again") { onRetry() }
    }
  }

  private func icon(_ systemName: String, tint: Color) -> some View {
    Image(systemName: systemName)
      .font(.system(size: 56))
      .foregroundColor(tint)
  }
}
