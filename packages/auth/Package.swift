// swift-tools-version: 6.3
import PackageDescription

let package = Package(
  name: "Auth",
  platforms: [
    .macOS(.v15),
    .iOS(.v26),
  ],
  products: [
    .library(
      name: "Auth",
      type: .dynamic,
      targets: ["Auth"]
    )
  ],
  dependencies: [
    .package(
      url: "https://github.com/vaariance/swift-java.git", branch: "peter/swift-java-callbackdeps"),
    .package(url: "https://github.com/apple/swift-crypto.git", "1.0.0"..<"4.0.0"),
    .package(name: "storage", path: "../storage"),
    .package(name: "hsm", path: "../hsm"),
    .package(name: "gateway", path: "../gateway"),
  ],
  targets: [
    .target(
      name: "Auth",
      dependencies: [
        .product(name: "SwiftJava", package: "swift-java"),
        .product(name: "Crypto", package: "swift-crypto"),
        .product(name: "Storage", package: "storage"),
        .product(name: "HSM", package: "hsm"),
        .product(name: "Gateway", package: "gateway"),
      ],
      path: "AuthCore/Sources/Auth",
      exclude: [
        "AppleAuthManager.swift",
        "swift-java.config",
      ],
      swiftSettings: [
        .swiftLanguageMode(.v5)
      ],
      plugins: [
        .plugin(name: "JExtractSwiftPlugin", package: "swift-java")
      ]
    )
  ]
)
