import SwiftUI
import UI

/// Step 1 of the send flow (#6a): enter an amount of the balance coin on a custom numeric keypad.
/// `onNext` hands the entered amount to the recipient step (#6c).
struct SendAmountView: View {
  @StateObject private var viewModel: SendAmountViewModel

  private let onNext: (Decimal) -> Void

  init(
    coinSymbol: String,
    maxFractionDigits: Int,
    suiAddress: String?,
    store: AppSessionStore,
    onNext: @escaping (Decimal) -> Void
  ) {
    _viewModel = StateObject(
      wrappedValue: SendAmountViewModel(
        coinSymbol: coinSymbol,
        maxFractionDigits: maxFractionDigits,
        suiAddress: suiAddress,
        store: store))
    self.onNext = onNext
  }

  var body: some View {
    VStack(spacing: 24) {
      Spacer()

      VStack(spacing: 4) {
        Text(viewModel.input.display)
          .font(.system(size: 64, weight: .semibold))
          .lineLimit(1)
          .minimumScaleFactor(0.4)
          .foregroundColor(viewModel.exceedsBalance ? .red : .primary)

        Text(viewModel.coinSymbol)
          .font(.title3)
          .foregroundColor(.secondary)

        // Reserve the line so the keypad doesn't jump when the message toggles.
        Text(viewModel.exceedsBalance ? "Insufficient balance" : " ")
          .font(.footnote)
          .foregroundColor(.red)
      }

      Spacer()

      QuickSelectChipsView(
        suggestions: viewModel.suggestions,
        isEnabled: { viewModel.isWithinBalance($0) },
        onSelect: { viewModel.select($0) }
      )

      NumericKeypadView { viewModel.handle($0) }

      UIButton("Next", isDisabled: !viewModel.canContinue) {
        onNext(viewModel.input.decimalValue)
      }
    }
    .padding(24)
    .navigationTitle("Send")
    .navigationBarTitleDisplayMode(.inline)
    .task { await viewModel.refreshBalance() }
  }
}
