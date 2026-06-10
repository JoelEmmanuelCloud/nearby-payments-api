import SwiftUI

/// A remote image fetched + cached through a `URLSession`/`URLCache` the app fully owns. Replaces
/// SwiftCache so Walrus aggregator blobs — served with no `Content-Type` — decode via `UIImage(data:)`
/// byte-sniffing, and any future fetch need (headers, fallback aggregators, retries) is a one-line
/// local edit rather than a fork. Renders the decoded image filled; shows nothing until loaded, so a
/// parent placeholder (e.g. `Avatar`'s person icon) sits behind it.
struct RemoteImage: View {
  let url: URL?

  @State private var uiImage: UIImage?

  var body: some View {
    Group {
      if let uiImage {
        Image(uiImage: uiImage)
          .resizable()
          .scaledToFill()
      }
    }
    .task(id: url) {
      uiImage = nil
      guard let url else { return }
      uiImage = await ImageLoader.shared.image(for: url)
    }
  }
}

/// Shared image cache. `URLCache` handles the disk tier (the Walrus aggregator sends
/// `Cache-Control: max-age=86400`, so cacheable HTTP responses persist for free); `NSCache` holds the
/// decoded images for instant re-display when re-entering a screen.
@MainActor
final class ImageLoader {
  static let shared = ImageLoader()

  private let memory = NSCache<NSURL, UIImage>()
  private let session: URLSession

  private init() {
    let configuration = URLSessionConfiguration.default
    configuration.urlCache = URLCache(memoryCapacity: 8 << 20, diskCapacity: 128 << 20)
    configuration.requestCachePolicy = .returnCacheDataElseLoad
    session = URLSession(configuration: configuration)
  }

  func image(for url: URL) async -> UIImage? {
    if let cached = memory.object(forKey: url as NSURL) { return cached }
    guard
      let (data, response) = try? await session.data(from: url),
      let http = response as? HTTPURLResponse, http.statusCode == 200,
      let image = UIImage(data: data)
    else { return nil }
    memory.setObject(image, forKey: url as NSURL)
    return image
  }
}
