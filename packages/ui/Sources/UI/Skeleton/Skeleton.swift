import SwiftUI

/// A shimmering placeholder shown while content loads. Size it with `.frame(...)`.
public struct Skeleton: View {
  private let cornerRadius: CGFloat

  @State private var animating = false

  public init(cornerRadius: CGFloat = 6) {
    self.cornerRadius = cornerRadius
  }

  public var body: some View {
    RoundedRectangle(cornerRadius: cornerRadius)
      .fill(.quaternary)
      .opacity(animating ? 0.35 : 0.9)
      .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: animating)
      .onAppear { animating = true }
  }
}

#Preview {
  Skeleton()
    .frame(width: 120, height: 22)
    .padding()
}
