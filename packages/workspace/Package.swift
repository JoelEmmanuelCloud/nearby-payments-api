// swift-tools-version: 6.3
import PackageDescription

let package = Package(
  name: "WorkspaceDependencies",
  platforms: [
    .iOS(.v26),
    .macOS(.v15),
  ],
  products: [
    .library(
      name: "WorkspaceDependencies",
      targets: ["WorkspaceDependencies"]
    )
  ],
  dependencies: [
    // --- Sui Dependencies ---
    // Note: SwiftyJSON and JWTDecode are now vendored into sui core
    // (Sources/Sui/Vendor); ed25519swift and CryptoSwift were replaced by
    // swift-crypto. None are external workspace deps any more.
    .package(url: "https://github.com/MarcoDotIO/UInt256.git", from: "1.0.0"),
    .package(url: "https://github.com/attaswift/BigInt.git", from: "5.3.0"),
    .package(url: "https://github.com/vaariance/apollo-ios.git", branch: "jextract-portable"),

    // --- Auth Dependencies ---
    .package(url: "https://github.com/google/GoogleSignIn-iOS.git", from: "9.0.0"),
    .package(url: "https://github.com/apple/swift-crypto.git", "1.0.0"..<"4.0.0"),

    // --- UI Dependencies ---
    .package(url: "https://github.com/sunghyun-k/swiftui-toasts", from: "1.1.2"),
  ],
  targets: [
    .target(
      name: "WorkspaceDependencies",
      path: "Sources"
    )
  ]
)
