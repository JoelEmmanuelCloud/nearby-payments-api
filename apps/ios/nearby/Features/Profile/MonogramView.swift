import SwiftUI

/// A circular monogram fallback shown when there's no avatar image.
struct MonogramView: View {
  let initial: Character

  var body: some View {
    Circle()
      .fill(Color.accentColor.opacity(0.15))
      .overlay(
        Text(String(initial).uppercased())
          .font(.system(size: 40, weight: .bold))
          .foregroundColor(.accentColor)
      )
  }
}

#Preview {
  MonogramView(initial: "a")
    .frame(width: 100, height: 100)
}
