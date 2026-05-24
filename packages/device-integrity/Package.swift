// swift-tools-version: 6.2
import PackageDescription

let package = Package(
  name: "DeviceIntegrity",
  platforms: [
    .iOS(.v26),
    .macOS(.v15),
  ],
  products: [
    .library(
      name: "DeviceIntegrity",
      targets: ["DeviceIntegrity"]
    ),
    .library(
      name: "SwiftDeviceIntegrity",
      type: .dynamic,
      targets: ["SwiftDeviceIntegrity"]
    ),
  ],
  dependencies: [
    .package(path: "../gateway"),
    .package(url: "https://github.com/swiftlang/swift-java", from: "0.3.0"),
  ],
  targets: [
    .target(
      name: "DeviceIntegrityShared",
      dependencies: [
        .product(name: "Gateway", package: "gateway")
      ],
      path: "Sources/Shared"
    ),
    .target(
      name: "DeviceIntegrity",
      dependencies: ["DeviceIntegrityShared"],
      path: "Sources/DeviceIntegrity"
    ),
    .target(
      name: "SwiftDeviceIntegrity",
      dependencies: [
        "DeviceIntegrityShared",
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
      name: "DeviceIntegrityTests",
      dependencies: ["DeviceIntegrity"],
      path: "Tests/DeviceIntegrityTests"
    ),
  ]
)
