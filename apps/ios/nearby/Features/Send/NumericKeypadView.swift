import SwiftUI

/// A key on the send keypad.
enum KeypadKey: Equatable {
  case digit(Int)
  case decimal
  case backspace
}

/// The custom 3×4 numeric keypad for entering a send amount. Stateless — it reports taps up and the
/// owner mutates the `AmountInput`.
struct NumericKeypadView: View {
  let onKey: (KeypadKey) -> Void

  private let rows: [[KeypadKey]] = [
    [.digit(1), .digit(2), .digit(3)],
    [.digit(4), .digit(5), .digit(6)],
    [.digit(7), .digit(8), .digit(9)],
    [.decimal, .digit(0), .backspace],
  ]

  var body: some View {
    VStack(spacing: 10) {
      ForEach(rows.indices, id: \.self) { row in
        HStack(spacing: 10) {
          ForEach(rows[row].indices, id: \.self) { column in
            key(rows[row][column])
          }
        }
      }
    }
  }

  private func key(_ key: KeypadKey) -> some View {
    Button {
      onKey(key)
    } label: {
      label(for: key)
        .font(.title2.weight(.medium))
        .foregroundColor(.primary)
        .frame(maxWidth: .infinity, minHeight: 56)
        .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
  }

  @ViewBuilder
  private func label(for key: KeypadKey) -> some View {
    switch key {
    case .digit(let value):
      Text(String(value))
    case .decimal:
      Text(".")
    case .backspace:
      Image(systemName: "delete.left")
    }
  }
}

#Preview {
  NumericKeypadView(onKey: { _ in })
    .padding()
}
