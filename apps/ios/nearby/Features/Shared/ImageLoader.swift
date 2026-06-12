import UIKit

/// Loads and caches remote images off the main actor. Built for Walrus aggregator blobs, but works
/// for any image URL.
///
/// Three Walrus aggregator traits shaped the design:
/// - **Immutable, content-addressed blobs.** A successful fetch can be cached forever, keyed by blob
///   id. So HTTP caching is bypassed entirely (`urlCache = nil`): `URLCache` would otherwise pin the
///   aggregator's *cacheable* 404s (`Cache-Control: public, max-age=3600`) and replay them long after
///   the blob certifies. We cache decoded images in memory and raw bytes on disk — successes only,
///   never failures.
/// - **No `Content-Type` header.** Irrelevant here: `UIImage(data:)` sniffs the bytes.
/// - **Cloudflare bot management.** It 403s some default UAs, so requests carry an explicit app UA.
///
/// Concurrent requests for the same URL are coalesced into one in-flight fetch.
actor ImageLoader {
  static let shared = ImageLoader()

  private let memory = NSCache<NSURL, UIImage>()

  private let session: URLSession

  private let diskDirectory: URL?

  private var inFlight: [URL: Task<UIImage?, Never>] = [:]

  private static let userAgent = "nearby-ios/1.0"

  init() {
    let configuration = URLSessionConfiguration.default
    configuration.urlCache = nil
    configuration.timeoutIntervalForRequest = 30
    session = URLSession(configuration: configuration)

    let caches = try? FileManager.default.url(
      for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    diskDirectory = caches?.appendingPathComponent("RemoteImages", isDirectory: true)
    if let diskDirectory {
      try? FileManager.default.createDirectory(at: diskDirectory, withIntermediateDirectories: true)
    }
  }

  /// The decoded image for `url`, from the fastest tier that has it (memory → disk → network), or nil
  /// if it can't be fetched/decoded. Callers requesting the same URL concurrently share one fetch.
  func image(for url: URL) async -> UIImage? {
    if let cached = memory.object(forKey: url as NSURL) { return cached }
    if let inProgress = inFlight[url] { return await inProgress.value }

    let task = Task { await load(url) }
    inFlight[url] = task
    let image = await task.value
    inFlight[url] = nil
    return image
  }

  // MARK: - Loading

  private func load(_ url: URL) async -> UIImage? {
    if let image = diskImage(for: url) {
      memory.setObject(image, forKey: url as NSURL)
      return image
    }

    guard let data = await fetchData(for: url), let image = UIImage(data: data) else { return nil }

    memory.setObject(image, forKey: url as NSURL)
    writeDisk(data, for: url)
    return image
  }

  /// Fetches the blob bytes, with one cache-busting retry for the upload-to-certification gap (where
  /// the first fetch can hit a pinned 404 even though the immutable blob is now live at a fresh key).
  private func fetchData(for url: URL) async -> Data? {
    if let data = await fetch(url) { return data }
    guard let bustedURL = cacheBustedURL(for: url) else { return nil }
    return await fetch(bustedURL)
  }

  private func fetch(_ url: URL) async -> Data? {
    var request = URLRequest(url: url)
    request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
    request.setValue(Self.userAgent, forHTTPHeaderField: "User-Agent")

    guard let (data, response) = try? await session.data(for: request),
      let http = response as? HTTPURLResponse
    else {
      debugPrint("ImageLoader: transport failure url=\(url)")
      return nil
    }
    guard http.statusCode == 200 else {
      debugPrint("ImageLoader: status=\(http.statusCode) url=\(url)")
      return nil
    }
    return data
  }

  // MARK: - Disk tier (raw bytes, keyed by immutable blob id)

  private func diskImage(for url: URL) -> UIImage? {
    guard let fileURL = diskFileURL(for: url),
      let data = try? Data(contentsOf: fileURL)
    else { return nil }
    return UIImage(data: data)
  }

  private func writeDisk(_ data: Data, for url: URL) {
    guard let fileURL = diskFileURL(for: url) else { return }
    try? data.write(to: fileURL)
  }

  /// Cache file keyed by the blob id (the URL's last path component — base64url, filename-safe).
  /// Blobs are immutable, so the entry never needs invalidation.
  private func diskFileURL(for url: URL) -> URL? {
    let blobID = url.lastPathComponent
    guard let diskDirectory, !blobID.isEmpty, blobID != "/" else { return nil }
    return diskDirectory.appendingPathComponent(blobID)
  }

  /// `url` with a throwaway query item appended, changing the cache key at the aggregator's Cloudflare
  /// edge so a pinned error response can't shadow a now-available blob.
  private func cacheBustedURL(for url: URL) -> URL? {
    guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
      return nil
    }
    var queryItems = components.queryItems ?? []
    queryItems.append(URLQueryItem(name: "cb", value: String(Int(Date.now.timeIntervalSince1970))))
    components.queryItems = queryItems
    return components.url
  }
}
