// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Gateway",
  platforms: [
    .iOS(.v17),
    .macOS(.v14),
  ],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "Gateway",
      targets: ["Gateway"]
    ),
    .library(
      name: "SwiftGateway",
      type: .dynamic,
      targets: ["SwiftGateway"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/swiftlang/swift-java", from: "0.3.0")
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "Gateway"
    ),
    .target(
      name: "SwiftGateway",
      dependencies: [
        "Gateway",
        .product(name: "SwiftJava", package: "swift-java"),
      ],
      path: "Sources/Java",
      swiftSettings: [
        .swiftLanguageMode(.v5)
      ],
      plugins: [
        .plugin(name: "JExtractSwiftPlugin", package: "swift-java")
      ]
    ),
    .testTarget(
      name: "GatewayTests",
      dependencies: ["Gateway"]
    ),
  ],
  swiftLanguageModes: [.v6]
)
