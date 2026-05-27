// swift-tools-version: 6.3
import PackageDescription

let package = Package(
  name: "SwiftGateway",
  platforms: [
    .iOS(.v26),
    .macOS(.v15),
  ],
  products: [
    .library(
      name: "Gateway",
      type: .dynamic,
      targets: ["Gateway"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/swiftlang/swift-java", exact: "0.4.0")
  ],
  targets: [
    .target(
      name: "Gateway",
      dependencies: [
        .product(name: "SwiftJava", package: "swift-java")
      ],
      path: "Core/Sources/Gateway",
      exclude: [
        "swift-java.config"
      ],
      swiftSettings: [
        .swiftLanguageMode(.v5)
      ],
      plugins: [
        .plugin(name: "JExtractSwiftPlugin", package: "swift-java")
      ]
    )
  ],
)
