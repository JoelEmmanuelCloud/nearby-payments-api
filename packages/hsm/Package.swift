// swift-tools-version: 6.3
import PackageDescription

let package = Package(
  name: "HSM",
  platforms: [
    .iOS(.v26),
    .macOS(.v15),
  ],
  products: [
    .library(
      name: "HSM",
      targets: ["HSM"]
    )
  ],
  dependencies: [],
  targets: [
    .target(
      name: "HSM",
      path: "Sources/HSM"
    ),
    .testTarget(
      name: "HSMTests",
      dependencies: ["HSM"],
      path: "Tests/HSMTests"
    ),
  ]
)
