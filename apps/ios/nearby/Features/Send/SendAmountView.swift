import LeanSui
import SwiftUI
import UI

/// Step 1 of the send flow (#6a): enter an amount of the balance coin on a custom numeric keypad. The
/// amount flows to the recipient screen (#6c), which sends and shows the result (#6d/#6e).
struct SendAmountView: View {
  @StateObject private var viewModel: SendAmountViewModel

  private let coinSymbol: String
  private let zkLoginService: ZkLoginService
  private let onFinish: () -> Void

  @State private var enteredAmount: Decimal?

  init(
    coinSymbol: String,
    maxFractionDigits: Int,
    suiAddress: String?,
    store: AppSessionStore,
    zkLoginService: ZkLoginService,
    onFinish: @escaping () -> Void
  ) {
    self.coinSymbol = coinSymbol
    self.zkLoginService = zkLoginService
    self.onFinish = onFinish
    _viewModel = StateObject(
      wrappedValue: SendAmountViewModel(
        coinSymbol: coinSymbol,
        maxFractionDigits: maxFractionDigits,
        suiAddress: suiAddress,
        store: store))
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
        enteredAmount = viewModel.input.decimalValue
      }
    }
    .padding(24)
    .navigationTitle("Send")
    .navigationBarTitleDisplayMode(.inline)
    .task { await viewModel.refreshBalance() }
    .navigationDestination(item: $enteredAmount) { amount in
      RecipientView(
        amount: amount,
        coinSymbol: coinSymbol,
        zkLoginService: zkLoginService,
        onFinish: onFinish
      )
    }
  }
}
