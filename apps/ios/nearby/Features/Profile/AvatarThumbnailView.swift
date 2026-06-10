import SwiftCache
import SwiftUI
import UI

/// The circular profile avatar — a thin app-level wrapper over the `ui.Avatar` primitive that maps the
/// app's image state (just-picked bytes, else a remote URL via SwiftCache) into the primitive's image
/// slot. When neither is present the primitive shows a monogram.
struct AvatarThumbnailView: View {
  let pickedAvatarData: Data?
  let avatarUrl: String?

  var body: some View {
    Avatar(size: 100) {
      if let picked = pickedAvatarData, let uiImage = UIImage(data: picked) {
        Image(uiImage: uiImage)
          .resizable()
          .scaledToFill()
      } else if let urlString = avatarUrl, let url = URL(string: urlString) {
        CachedImage(url: url) {
          EmptyView()
        }
        .scaledToFill()
      }
    }
  }
}

#Preview {
  AvatarThumbnailView(pickedAvatarData: nil, avatarUrl: nil)
}
