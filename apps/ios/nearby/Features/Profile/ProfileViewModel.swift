import Combine
import DeviceIntegrity
import Foundation
import Gateway
import Identity
import LeanSuiApi
import UI

@MainActor
final class ProfileViewModel: ObservableObject {
  /// True until the first profile resolution (cache prefill or remote fetch) completes. The main
  /// page's badge shows a spinner while this is true, so the screen never renders a wrong state.
  @Published
  private(set) var isLoading = true

  /// The registered SuiNS name, or nil if the user has none. Single source of truth for "registered".
  @Published
  private(set) var suinsName: String?

  /// The stable zkLogin address, read from the session (never derived here).
  @Published
  private(set) var suiAddress: String?

  /// Remote avatar URL — rendered (and disk-cached) by the image loader. No image blobs are stored.
  @Published
  private(set) var avatarUrl: String?

  /// A just-picked local image, shown immediately while the upload/URL round-trips.
  @Published
  private(set) var pickedAvatarData: Data?

  // MARK: Edit-screen state

  /// The raw name being edited; validated (not stripped) in `onNameInputChange`.
  @Published
  private(set) var nameInput = ""

  @Published
  private(set) var statusMessage: String?

  @Published
  private(set) var isAvailable = false

  @Published
  private(set) var isSaving = false

  private let identityManager: IdentityManager
  private let store: AppSessionStore
  private let toastController: ToastController
  private let userId: String

  private var nameCheckTask: Task<Void, Never>?

  init(
    identityManager: IdentityManager,
    store: AppSessionStore,
    toastController: ToastController,
    suiAddress: String?,
    userId: String
  ) {
    self.identityManager = identityManager
    self.store = store
    self.toastController = toastController
    self.userId = userId
    // The stable zkLogin address is resolved by the app coordinator (`currentSuiAddress`) and passed
    // in — the profile layer only consumes it, never reads the session itself.
    self.suiAddress = suiAddress
    // Prefill the avatar from the cache so the tab icon (which observes this model) shows immediately
    // on launch, before the Profile screen is ever opened. `loadProfile` refreshes it from remote.
    self.avatarUrl = store.cachedProfile(userId: userId)?.avatarUrl
  }

  /// Whether the user has a registered name (drives the badge: registered vs. set-up).
  var isRegistered: Bool {
    suinsName != nil
  }

  /// The display string for the main page, e.g. "alice.nearby.sui" or the dummy placeholder.
  var displayName: String {
    if let suinsName { return "\(suinsName).variance.sui" }
    return "yourname.variance"
  }

  func loadProfile() {
    // 1. Prefill from the app-side cache for an instant badge resolution on re-entry.
    if let cached = store.cachedProfile(userId: userId) {
      applyProfile(cached)
      isLoading = false
    }

    // 2. Fetch fresh in the background.
    Task {
      defer { isLoading = false }
      guard let addr = suiAddress else { return }
      do {
        let remoteProfile = try await identityManager.fetchProfile(suiAddress: addr)
        applyProfile(remoteProfile)
        store.cacheProfile(remoteProfile)
      } catch {
        // Offline / backend down → keep whatever the cache prefilled.
      }
    }
  }

  private func applyProfile(_ profile: IdentityProfile) {
    suinsName = (profile.suinsName?.isEmpty == false) ? profile.suinsName : nil
    avatarUrl = profile.avatarUrl
  }

  // MARK: - Name editing

  /// Clears transient name-entry state so the edit screen always starts fresh (the shared view model
  /// otherwise retains the last "available" message after you leave and re-enter).
  func resetNameEntry() {
    nameCheckTask?.cancel()
    nameInput = ""
    statusMessage = nil
    isAvailable = false
  }

  /// Entry point from the edit field: store the raw text, validate it, and debounce an availability
  /// check. Invalid input (e.g. a space) is rejected outright rather than silently stripped.
  func onNameInputChange(_ raw: String) {
    nameInput = raw

    nameCheckTask?.cancel()
    isAvailable = false

    guard suinsName == nil else { return }

    switch LeafNameInput.parse(raw) {
    case .empty:
      statusMessage = nil
    case .invalid:
      statusMessage = "Use letters, numbers, and hyphens only."
    case .valid(let name):
      statusMessage = nil
      nameCheckTask = Task {
        try? await Task.sleep(
          nanoseconds: UInt64(AppConstants.nameCheckDebounce * 1_000_000_000))
        guard !Task.isCancelled else { return }
        await checkName(name)
      }
    }
  }

  private func checkName(_ name: String) async {
    statusMessage = "Checking availability..."
    let manager = identityManager
    do {
      let res = try await withTimeout(seconds: AppConstants.networkTimeout) {
        try await manager.checkNameAvailability(leafName: name)
      }
      isAvailable = res.available
      statusMessage = res.available ? "Name is available!" : "Name is already taken."
    } catch is TimeoutError {
      statusMessage = nil
      toastController.show("Name check timed out. Check your connection.", tone: .warning)
    } catch {
      // Non-timeout failure: stay quiet — the status message is enough, and a toast here misfires.
      statusMessage = nil
    }
  }

  func registerName() async {
    guard isAvailable, suinsName == nil,
      case .valid(let name) = LeafNameInput.parse(nameInput)
    else { return }
    isSaving = true
    statusMessage = "Registering name..."
    do {
      let deviceProvider = AppAttestProvider.provider

      let regRes = try await identityManager.registerName(
        leafName: name,
        deviceProvider: deviceProvider
      )

      statusMessage = "Polling registration status..."
      _ = try await identityManager.pollNameTask(
        taskId: regRes.taskId,
        deviceProvider: deviceProvider
      )

      isSaving = false
      suinsName = name
      statusMessage = nil

      if let suiAddress,
        let refreshed = try? await identityManager.fetchProfile(suiAddress: suiAddress)
      {
        applyProfile(refreshed)
        store.cacheProfile(refreshed)
      }
    } catch {
      isSaving = false
      statusMessage = nil
      toastController.show("Registration failed")
    }
  }

  func uploadAvatar(data: Data) async {
    isSaving = true
    pickedAvatarData = data  // show the picked image immediately
    statusMessage = "Uploading avatar..."
    do {
      let newUrl = try await identityManager.updateAvatar(
        data: Array(data), contentType: "image/jpeg")
      avatarUrl = newUrl

      // Refresh the app-side cached profile with the new avatar URL, if we have one cached.
      if let cached = store.cachedProfile(userId: userId) {
        store.cacheProfile(
          IdentityProfile(
            userId: cached.userId,
            status: cached.status,
            avatarUrl: newUrl,
            suiAddress: cached.suiAddress,
            suinsName: cached.suinsName,
            createdAt: cached.createdAt))
      }

      isSaving = false
      statusMessage = nil
    } catch {
      isSaving = false
      statusMessage = nil
      toastController.show("Avatar upload failed")
    }
  }
}
