import SwiftUI

/// The row of predictive quick-select chips above the keypad. Stateless — it renders the suggested
/// amounts and reports taps; chips that exceed the balance are disabled.
struct QuickSelectChipsView: View {
  let suggestions: [Decimal]
  let isEnabled: (Decimal) -> Bool
  let onSelect: (Decimal) -> Void

  var body: some View {
    HStack(spacing: 8) {
      ForEach(suggestions, id: \.self) { value in
        let enabled = isEnabled(value)
        Button {
          onSelect(value)
        } label: {
          Text(value.formatted(.number.grouping(.automatic)))
            .font(.subheadline.weight(.medium))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(Color(.secondarySystemBackground))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .foregroundColor(.primary)
        .disabled(!enabled)
        .opacity(enabled ? 1 : 0.4)
      }
    }
  }
}

#Preview {
  QuickSelectChipsView(
    suggestions: [50, 500, 5000],
    isEnabled: { $0 <= 1000 },
    onSelect: { _ in }
  )
  .padding()
}
