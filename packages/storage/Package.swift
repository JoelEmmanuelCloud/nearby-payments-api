// swift-tools-version: 6.3
import PackageDescription

let package = Package(
  name: "Storage",
  platforms: [
    .macOS(.v15),
    .iOS(.v26),
  ],
  products: [
    .library(
      name: "Storage",
      type: .dynamic,
      targets: ["Storage"]
    )
  ],
  dependencies: [
    .package(
      url: "https://github.com/vaariance/swift-java.git", branch: "peter/swift-java-callbackdeps")
  ],
  targets: [
    .target(
      name: "Storage",
      dependencies: [
        .product(name: "SwiftJava", package: "swift-java")
      ],
      path: "StorageCore/Sources/Storage",
      exclude: [
        "KeychainProvider.swift",
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
