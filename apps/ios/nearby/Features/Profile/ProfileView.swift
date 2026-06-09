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

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 24) {
          AvatarPickerView(
            selection: $selectedItem,
            pickedAvatarData: viewModel.pickedAvatarData,
            avatarUrl: viewModel.avatarUrl,
            monogramInitial: viewModel.suinsName?.first ?? "U",
            isSaving: viewModel.isSaving
          )

          // Identity: name + resolving badge
          Card {
            VStack(alignment: .leading, spacing: 16) {
              Text("Nearby Identity")
                .font(.headline)

              HStack(spacing: 8) {
                Image(systemName: viewModel.isRegistered ? "checkmark.seal.fill" : "at")
                  .foregroundColor(viewModel.isRegistered ? .green : .secondary)

                Text(viewModel.displayName)
                  .font(.title3.weight(.medium))
                  .foregroundColor(viewModel.isRegistered ? .primary : .secondary)

                Spacer()

                ProfileStatusBadge(
                  isLoading: viewModel.isLoading,
                  isRegistered: viewModel.isRegistered,
                  onSetUp: {
                    viewModel.resetNameEntry()
                    showEdit = true
                  }
                )
              }
            }
          }

          // Wallet address
          Card {
            VStack(alignment: .leading, spacing: 10) {
              Text("Sui Wallet Address")
                .font(.headline)

              if let addr = viewModel.suiAddress {
                Text(addr)
                  .font(.system(.footnote, design: .monospaced))
                  .foregroundColor(.secondary)
                  .multilineTextAlignment(.leading)
                  .contextMenu {
                    Button {
                      UIPasteboard.general.string = addr
                    } label: {
                      Label("Copy Address", systemImage: "doc.on.doc")
                    }
                  }
              } else {
                MutedText("Deriving Sui zkLogin address...")
              }
            }
          }

          if viewModel.isSetupMode {
            SecondaryButton("Skip for Now") {
              viewModel.onFinish()
            }
            .disabled(viewModel.isSaving)
          }
        }
        .padding(24)
      }
      .navigationTitle(viewModel.isSetupMode ? "Set up profile" : "Profile")
      .navigationBarTitleDisplayMode(.inline)
      .navigationDestination(isPresented: $showEdit) {
        ProfileEditView(viewModel: viewModel)
      }
      .toolbar {
        if !viewModel.isSetupMode {
          ToolbarItem(placement: .navigationBarLeading) {
            Button("Back") { viewModel.onFinish() }
          }
        }
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
