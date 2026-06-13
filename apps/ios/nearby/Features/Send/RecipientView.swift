import LeanSui
import SwiftUI
import UI

/// The second (and final input) screen of the send flow (#6c/#6d): enter the recipient as a SuiNS
/// name or `0x` address, then send. The field shows a live idle → resolving → ✓ / ✗ state; the
/// bottom-pinned "Send" button executes the gasless transfer inline and, once it settles, pushes the
/// success / failure result (#6e).
struct RecipientView: View {
  let amount: Decimal
  let coinSymbol: String
  let onFinish: () -> Void

  @StateObject private var viewModel = RecipientViewModel()
  @StateObject private var sendModel: SendViewModel

  @State private var result: SendResultView.Outcome?

  @FocusState private var fieldFocused: Bool

  init(
    amount: Decimal, coinSymbol: String, signerProvider: @escaping SignerProvider,
    onFinish: @escaping () -> Void
  ) {
    self.amount = amount
    self.coinSymbol = coinSymbol
    self.onFinish = onFinish
    let service = SendService(signerProvider: signerProvider)
    _sendModel = StateObject(
      wrappedValue: SendViewModel(amount: amount, coinSymbol: coinSymbol, service: service))
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 20) {
      MutedText("Sending \(amount.formatted(.number.grouping(.automatic))) \(coinSymbol)")

      HStack(spacing: 8) {
        Input("name.sui or 0x address", text: fieldBinding)
          .focused($fieldFocused)
          .disabled(sendModel.isSending)

        status
      }
      .padding(14)
      .background(Color(.secondarySystemBackground))
      .clipShape(RoundedRectangle(cornerRadius: 12))

      detail

      Spacer()

      UIButton(
        sendModel.isSending ? "Sending…" : "Send",
        isDisabled: viewModel.resolvedAddress == nil || sendModel.isSending
      ) {
        Task { await send() }
      }
    }
    .padding(24)
    .navigationTitle("Recipient")
    .navigationBarTitleDisplayMode(.inline)
    .navigationBarBackButtonHidden(sendModel.isSending)
    .onAppear { fieldFocused = true }
    .navigationDestination(item: $result) { outcome in
      SendResultView(
        outcome: outcome,
        amount: amount,
        coinSymbol: coinSymbol,
        recipient: viewModel.resolvedAddress ?? "",
        onDone: onFinish,
        onRetry: { result = nil }
      )
    }
  }

  private func send() async {
    guard let address = viewModel.resolvedAddress else { return }
    fieldFocused = false
    await sendModel.send(to: address)
    switch sendModel.state {
    case .success(let digest): result = .success(digest: digest)
    case .failure(let message): result = .failure(message: message)
    case .idle, .sending: break
    }
  }

  private var fieldBinding: Binding<String> {
    Binding(
      get: { viewModel.input },
      set: { viewModel.onInputChange($0) }
    )
  }

  @ViewBuilder
  private var status: some View {
    switch viewModel.state {
    case .resolving:
      ProgressView()
    case .resolved:
      Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
    case .invalid, .notFound:
      Image(systemName: "xmark.circle.fill").foregroundColor(.red)
    case .idle:
      EmptyView()
    }
  }

  @ViewBuilder
  private var detail: some View {
    switch viewModel.state {
    case .resolved(let address, let name):
      // Show where a name points; for a raw address there's nothing more to say.
      if name != nil {
        Text("→ \(shortSuiAddress(address))")
          .font(.footnote.monospaced())
          .foregroundColor(.green)
      }
    case .notFound:
      Text("Name not found")
        .font(.footnote)
        .foregroundColor(.red)
    case .invalid:
      Text("Enter a valid .sui name or 0x address")
        .font(.footnote)
        .foregroundColor(.secondary)
    case .idle, .resolving:
      EmptyView()
    }
  }
}
