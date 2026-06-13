import SwiftUI

/// A circular avatar. Loader-agnostic: pass the resolved image view (e.g. `CachedImage` / `AsyncImage`)
/// as `content`; when none is supplied it shows a system person placeholder. The `ui` package stays
/// free of any image-loading dependency.
public struct Avatar<Content: View>: View {
  private let size: CGFloat
  private let content: Content

  public init(
    size: CGFloat = 100,
    @ViewBuilder content: () -> Content
  ) {
    self.size = size
    self.content = content()
  }

  public var body: some View {
    ZStack {
      Image(systemName: "person.crop.circle")
        .resizable()
        .scaledToFit()
        .foregroundStyle(.tertiary)

      // The supplied image (if any) overlays and covers the placeholder.
      content
    }
    .frame(width: size, height: size)
    .clipShape(Circle())
    .overlay(Circle().stroke(.quaternary, lineWidth: 1))
  }
}

extension Avatar where Content == EmptyView {
  /// Placeholder-only avatar (no image).
  public init(size: CGFloat = 100) {
    self.init(size: size) { EmptyView() }
  }
}

#Preview {
  HStack(spacing: 16) {
    Avatar()
    Avatar(size: 44)
  }
  .padding()
}
