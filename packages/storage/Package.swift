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
    .package(url: "https://github.com/swiftlang/swift-java", exact: "0.4.0")
  ],
  targets: [
    .target(
      name: "Storage",
      dependencies: [
        .product(name: "SwiftJava", package: "swift-java")
      ],
      path: "Core/Sources/Storage",
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
