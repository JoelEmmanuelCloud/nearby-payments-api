import SwiftCache
import SwiftUI

/// The circular profile avatar: a just-picked local image, else the remote URL (memory+disk cached
/// by SwiftCache), else a monogram.
struct AvatarThumbnailView: View {
  let pickedAvatarData: Data?
  let avatarUrl: String?
  let monogramInitial: Character

  var body: some View {
    Group {
      if let picked = pickedAvatarData, let uiImage = UIImage(data: picked) {
        Image(uiImage: uiImage)
          .resizable()
          .scaledToFill()
      } else if let urlString = avatarUrl, let url = URL(string: urlString) {
        CachedImage(url: url) {
          MonogramView(initial: monogramInitial)
        }
        .scaledToFill()
      } else {
        MonogramView(initial: monogramInitial)
      }
    }
    .frame(width: 100, height: 100)
    .clipShape(Circle())
    .overlay(Circle().stroke(Color(uiColor: .separator), lineWidth: 1))
    .shadow(radius: 2)
  }
}

#Preview {
  AvatarThumbnailView(pickedAvatarData: nil, avatarUrl: nil, monogramInitial: "a")
}
