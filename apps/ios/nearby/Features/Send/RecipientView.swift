import SwiftUI
import UI

/// Step 2 of the send flow (#6c): enter the recipient as a SuiNS name or `0x` address. The field shows
/// a live idle → resolving → ✓ / ✗ state; `onContinue` hands the resolved address to #6d.
struct RecipientView: View {
  let amount: Decimal
  let coinSymbol: String
  let onContinue: (String) -> Void

  @StateObject private var viewModel = RecipientViewModel()

  @FocusState private var fieldFocused: Bool

  var body: some View {
    VStack(alignment: .leading, spacing: 20) {
      MutedText("Sending \(amount.formatted(.number.grouping(.automatic))) \(coinSymbol)")

      HStack(spacing: 8) {
        Input("name.sui or 0x address", text: fieldBinding)
          .focused($fieldFocused)

        status
      }
      .padding(14)
      .background(Color(.secondarySystemBackground))
      .clipShape(RoundedRectangle(cornerRadius: 12))

      detail

      Spacer()

      UIButton("Continue", isDisabled: viewModel.resolvedAddress == nil) {
        if let address = viewModel.resolvedAddress {
          onContinue(address)
        }
      }
    }
    .padding(24)
    .navigationTitle("Recipient")
    .navigationBarTitleDisplayMode(.inline)
    .onAppear { fieldFocused = true }
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
