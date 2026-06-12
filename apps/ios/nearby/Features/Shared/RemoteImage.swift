import SwiftUI

/// Asynchronously loads `url` through `ImageLoader` and renders it filled. Shows nothing until the
/// image resolves, so a parent placeholder (e.g. `Avatar`'s person icon) shows through underneath.
struct RemoteImage: View {
  let url: URL?

  @State private var image: UIImage?

  var body: some View {
    // A stable, always-present container is required: `.task` only runs while its view is installed,
    // and a bare `if let image` renders nothing (so nothing to attach to) until the load completes —
    // which never starts. `Color.clear` keeps the task alive and lets the parent size the view.
    Color.clear
      .overlay {
        if let image {
          Image(uiImage: image)
            .resizable()
            .scaledToFill()
        }
      }
      .task(id: url) {
        image = nil
        guard let url else { return }
        image = await ImageLoader.shared.image(for: url)
      }
  }
}
