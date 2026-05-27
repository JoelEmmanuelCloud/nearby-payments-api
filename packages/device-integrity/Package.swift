// swift-tools-version: 6.23
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
    )
  ],
  dependencies: [
    .package(path: "../gateway/core")
  ],
  targets: [
    .target(
      name: "DeviceIntegrity",
      dependencies: [
        .product(name: "Gateway", package: "gateway")
      ],
      path: "Sources/DeviceIntegrity"
    ),
    .testTarget(
      name: "DeviceIntegrityTests",
      dependencies: ["DeviceIntegrity"],
      path: "Tests/DeviceIntegrityTests"
    ),
  ]
)
