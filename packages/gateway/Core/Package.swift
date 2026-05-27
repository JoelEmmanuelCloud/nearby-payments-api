// swift-tools-version: 6.3
import PackageDescription

let package = Package(
  name: "Gateway",
  platforms: [
    .iOS(.v26),
    .macOS(.v15),
  ],
  products: [
    .library(
      name: "Gateway",
      targets: ["Gateway"]
    )
  ],
  targets: [
    .target(
      name: "Gateway",
      path: "Sources/Gateway",
      exclude: [
        "swift-java.config"
      ],
    ),
    .testTarget(
      name: "GatewayTests",
      dependencies: ["Gateway"],
      path: "Tests/GatewayTests",
    ),
  ],
)
