import SwiftUI

public struct Card<Content: View>: View {
  private let content: Content

  public init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      content
    }
    .padding(16)
    .background(.background)
    .clipShape(RoundedRectangle(cornerRadius: 8))
    .overlay {
      RoundedRectangle(cornerRadius: 8)
        .stroke(.quaternary)
    }
  }
}

#Preview {
  VStack(spacing: 12) {
    Card {
      Text("i have steeze")
    }
  }
  .padding()
}
