// swift-tools-version: 6.3
// Outer manifest: builds LeanSui as a product for swift-java,
// sourcing from the inner LeanSuiCore package-in-package.
import PackageDescription

let package = Package(
  name: "LeanSui",
  platforms: [
    .iOS(.v26),
    .macOS(.v15),
  ],
  products: [
    .library(
      name: "LeanSui",
      type: .dynamic,
      targets: ["LeanSui"]
    )
  ],
  dependencies: [
    .package(
      url: "https://github.com/vaariance/swift-java.git", branch: "peter/swift-java-callbackdeps"),
    .package(url: "https://github.com/MarcoDotIO/UInt256.git", from: "1.0.0"),
    .package(url: "https://github.com/attaswift/BigInt.git", from: "5.3.0"),
    // swift-crypto provides cross-platform Ed25519 (Curve25519.Signing),
    // replacing ed25519swift/CryptoSwift (both Darwin-locked).
    .package(url: "https://github.com/apple/swift-crypto.git", "1.0.0"..<"4.0.0"),
    // HSM provides the Java-callback protocol for hardware-backed signing.
    .package(name: "HSM", path: "../hsm"),
    // The GraphQL Sui client lives in the sibling sui-api package (LeanSuiApi).
    .package(name: "LeanSuiApi", path: "../sui-api"),
    // The cross-platform BCS serializer lives in the sibling sui-bcs package.
    .package(name: "LeanSuiBCS", path: "../sui-bcs"),
  ],
  targets: [
    .target(
      name: "LeanSui",
      dependencies: [
        .product(name: "SwiftJava", package: "swift-java"),
        .product(name: "BigInt", package: "BigInt"),
        .product(name: "UInt256", package: "UInt256"),
        .product(name: "Crypto", package: "swift-crypto"),
        .product(name: "HSM", package: "HSM"),
        .product(name: "LeanSuiApi", package: "LeanSuiApi"),
        .product(name: "LeanSuiBCS", package: "LeanSuiBCS"),
      ],
      path: "LeanSuiCore/Sources/LeanSui",
      exclude: [
        "swift-java.config"
      ],
      swiftSettings: [
        .swiftLanguageMode(.v5)
      ],
      plugins: [
        .plugin(name: "JExtractSwiftPlugin", package: "swift-java")
      ]
    ),
    .testTarget(
      name: "LeanSuiTests",
      dependencies: ["LeanSui"],
      path: "LeanSuiCore/Tests/LeanSuiTests"
    ),
  ]
)
