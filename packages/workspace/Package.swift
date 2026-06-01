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
    .package(url: "https://github.com/MarcoDotIO/UInt256.git", from: "1.0.0"),
    .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "4.0.0"),
    .package(url: "https://github.com/auth0/JWTDecode.swift", from: "3.1.0"),
    .package(url: "https://github.com/attaswift/BigInt.git", from: "5.3.0"),
    .package(url: "https://github.com/vaariance/apollo-ios.git", branch: "jextract-portable"),
    .package(url: "https://github.com/pebble8888/ed25519swift.git", from: "1.2.8"),
    .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.8.0"),

    // --- Auth Dependencies ---
    .package(url: "https://github.com/google/GoogleSignIn-iOS.git", from: "7.1.0"),
    .package(url: "https://github.com/apple/swift-crypto.git", "1.0.0"..<"4.0.0"),
  ],
  targets: [
    .target(
      name: "WorkspaceDependencies",
      path: "Sources"
    )
  ]
)
