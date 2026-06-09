import Auth
import Combine
import DeviceIntegrity
import Foundation
import Gateway
import Identity
import LeanSuiApi

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

  /// The sanitized name being edited. Written only via `onNameInputChange`.
  @Published
  private(set) var nameInput = ""

  @Published
  private(set) var statusMessage: String?

  @Published
  private(set) var isAvailable = false

  @Published
  private(set) var isSaving = false

  let isSetupMode: Bool
  let onFinish: () -> Void

  private let identityManager: IdentityManager
  private let sessionManager: SessionManager
  private let store: AppSessionStore

  private var nameCheckTask: Task<Void, Never>?

  init(
    identityManager: IdentityManager,
    sessionManager: SessionManager,
    store: AppSessionStore,
    isSetupMode: Bool,
    onFinish: @escaping () -> Void
  ) {
    self.identityManager = identityManager
    self.sessionManager = sessionManager
    self.store = store
    self.isSetupMode = isSetupMode
    self.onFinish = onFinish
  }

  /// Whether the user has a registered name (drives the badge: registered vs. set-up).
  var isRegistered: Bool {
    suinsName != nil
  }

  /// The display string for the main page, e.g. "alice.nearby.sui" or the dummy placeholder.
  var displayName: String {
    if let suinsName { return "\(suinsName).nearby.sui" }
    return "yourname.nearby.sui"
  }

  func loadProfile() {
    // 1. Read the stable address the zkLogin layer persisted at login (fast keychain read).
    loadAddress()

    // 2. Prefill from the app-side cache for an instant badge resolution on re-entry.
    if let userId = try? sessionManager.getCurrentSession()?.userId,
      let cached = store.cachedProfile(userId: userId)
    {
      applyProfile(cached)
      isLoading = false
    }

    // 3. Fetch fresh in the background.
    Task {
      defer { isLoading = false }
      guard let addr = suiAddress else { return }
      do {
        let remoteProfile = try await identityManager.fetchProfile(suiAddress: addr)
        applyProfile(remoteProfile)
        store.cacheProfile(remoteProfile)

        // Setup mode + already-registered → skip straight to home.
        if isSetupMode, suinsName != nil {
          onFinish()
        }
      } catch {
        // Offline / backend down → keep whatever the cache prefilled.
      }
    }
  }

  private func applyProfile(_ profile: IdentityProfile) {
    suinsName = (profile.suinsName?.isEmpty == false) ? profile.suinsName : nil
    avatarUrl = profile.avatarUrl
  }

  /// Reads the stable Sui address persisted by `ZkLoginService.commitSessionIdentity` at login. The
  /// profile layer only consumes the address — it never derives it. If absent (a pre-commit/stale
  /// session) it stays nil and the UI degrades gracefully; a re-login repopulates it.
  private func loadAddress() {
    guard
      let session = try? sessionManager.getCurrentSession(),
      let addr = session.suiAddress, !addr.isEmpty
    else { return }
    suiAddress = addr
  }

  // MARK: - Name editing

  /// SuiNS labels are lowercase `[a-z0-9-]` — strip everything else so the gateway never sees an
  /// invalid name (a space used to error).
  static func sanitize(_ raw: String) -> String {
    raw.lowercased().filter { $0.isASCII && ($0.isLetter || $0.isNumber || $0 == "-") }
  }

  /// Clears transient name-entry state so the edit screen always starts fresh (the shared view model
  /// otherwise retains the last "available" message after you leave and re-enter).
  func resetNameEntry() {
    nameCheckTask?.cancel()
    nameInput = ""
    statusMessage = nil
    isAvailable = false
  }

  /// Entry point from the edit field: sanitize, store, and debounce an availability check.
  func onNameInputChange(_ raw: String) {
    let clean = Self.sanitize(raw)
    nameInput = clean

    nameCheckTask?.cancel()
    isAvailable = false
    statusMessage = nil

    guard !clean.isEmpty, suinsName == nil else { return }

    nameCheckTask = Task {
      try? await Task.sleep(nanoseconds: 500_000_000)  // Debounce 500ms
      guard !Task.isCancelled else { return }
      await checkName(clean)
    }
  }

  private func checkName(_ name: String) async {
    statusMessage = "Checking availability..."
    do {
      let res = try await identityManager.checkNameAvailability(leafName: name)
      isAvailable = res.available
      statusMessage = res.available ? "Name is available!" : "Name is already taken."
    } catch {
      statusMessage = "Could not verify name: \(error.localizedDescription)"
    }
  }

  func registerName() async {
    guard isAvailable, !nameInput.isEmpty, suinsName == nil else { return }
    isSaving = true
    statusMessage = "Registering name..."
    do {
      let deviceProvider = AppAttestProvider.provider

      let regRes = try await identityManager.registerName(
        leafName: nameInput,
        deviceProvider: deviceProvider
      )

      statusMessage = "Polling registration status..."
      _ = try await identityManager.pollNameTask(
        taskId: regRes.taskId,
        deviceProvider: deviceProvider
      )

      isSaving = false
      suinsName = nameInput
      statusMessage = "Name registered successfully!"

      if let suiAddress,
        let refreshed = try? await identityManager.fetchProfile(suiAddress: suiAddress)
      {
        applyProfile(refreshed)
        store.cacheProfile(refreshed)
      }

      if isSetupMode {
        onFinish()
      }
    } catch {
      isSaving = false
      statusMessage = "Registration failed: \(error.localizedDescription)"
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
      if let userId = try? sessionManager.getCurrentSession()?.userId,
        let cached = store.cachedProfile(userId: userId)
      {
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
      statusMessage = "Avatar updated!"
    } catch {
      isSaving = false
      statusMessage = "Avatar upload failed: \(error.localizedDescription)"
    }
  }
}
