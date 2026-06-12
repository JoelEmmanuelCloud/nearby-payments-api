import PhotosUI
import SwiftUI
import UI

/// The display-first profile page. Everything except the small status badge renders immediately; the
/// badge resolves loading → "Registered" / "Set up name", so the screen never flips between an edit
/// and a locked layout. Editing happens on a pushed `ProfileEditView`.
struct ProfileView: View {
  @ObservedObject var viewModel: ProfileViewModel

  @State private var selectedItem: PhotosPickerItem?

  @State private var showEdit = false

  @State private var addressCopied = false

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 24) {
          AvatarPickerView(
            selection: $selectedItem,
            pickedAvatarData: viewModel.pickedAvatarData,
            avatarUrl: viewModel.avatarUrl,
            isSaving: viewModel.isSaving
          )

          // Identity: name + resolving badge
          Card {
            VStack(alignment: .leading, spacing: 16) {
              Text("Sui Identity")
                .font(.headline)

              if viewModel.isLoading {
                HStack(spacing: 8) {
                  Skeleton(cornerRadius: 11)
                    .frame(width: 22, height: 22)
                  Skeleton()
                    .frame(width: 150, height: 22)
                  Spacer()
                  Skeleton(cornerRadius: 8)
                    .frame(width: 96, height: 28)
                }
              } else {
                HStack(spacing: 8) {
                  Image(systemName: viewModel.isRegistered ? "checkmark.seal.fill" : "at")
                    .foregroundColor(viewModel.isRegistered ? .green : .secondary)

                  Text(viewModel.displayName)
                    .font(.title3.weight(.medium))
                    .foregroundColor(viewModel.isRegistered ? .primary : .secondary)

                  Spacer()

                  ProfileStatusBadge(
                    isRegistered: viewModel.isRegistered,
                    onSetUp: {
                      viewModel.resetNameEntry()
                      showEdit = true
                    }
                  )
                }
              }
            }
          }

          // Wallet address — tap the card to copy
          Card {
            VStack(alignment: .leading, spacing: 10) {
              HStack {
                Text("Sui Wallet Address")
                  .font(.headline)

                Spacer()

                if viewModel.suiAddress != nil {
                  Text(addressCopied ? "copied" : "tap to copy")
                    .font(.caption)
                    .foregroundColor(addressCopied ? .green : .secondary)
                }
              }

              if let addr = viewModel.suiAddress {
                Text(addr)
                  .font(.system(.footnote, design: .monospaced))
                  .foregroundColor(.secondary)
                  .multilineTextAlignment(.leading)
              } else {
                MutedText("Deriving Sui zkLogin address...")
              }
            }
          }
          .contentShape(Rectangle())
          .onTapGesture {
            guard let addr = viewModel.suiAddress else { return }
            UIPasteboard.general.string = addr
            addressCopied = true
            Task {
              try? await Task.sleep(nanoseconds: 2_000_000_000)
              addressCopied = false
            }
          }

        }
        .padding(24)
      }
      .navigationTitle("Profile")
      .navigationDestination(isPresented: $showEdit) {
        ProfileEditView(viewModel: viewModel)
      }
      .onChange(of: selectedItem) { _, newItem in
        if let newItem {
          Task {
            if let data = try? await newItem.loadTransferable(type: Data.self) {
              await viewModel.uploadAvatar(data: data)
            }
          }
        }
      }
      .onAppear {
        viewModel.loadProfile()
      }
    }
  }
}
