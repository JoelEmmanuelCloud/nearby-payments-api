import PhotosUI
import SwiftUI

/// The tappable avatar + photo picker. It takes plain values (not the `@MainActor` view model) so the
/// `PhotosPicker` label closure — treated as `@Sendable` under strict concurrency — doesn't capture
/// actor-isolated state.
struct AvatarPickerView: View {
  @Binding var selection: PhotosPickerItem?

  let pickedAvatarData: Data?
  let avatarUrl: String?
  let isSaving: Bool

  var body: some View {
    VStack(spacing: 12) {
      PhotosPicker(selection: $selection, matching: .images, photoLibrary: .shared()) {
        AvatarThumbnailView(
          pickedAvatarData: pickedAvatarData,
          avatarUrl: avatarUrl
        )
      }
      .disabled(isSaving)

      Text("Tap photo to update")
        .font(.caption)
        .foregroundColor(.secondary)
    }
    .padding(.top, 16)
  }
}
