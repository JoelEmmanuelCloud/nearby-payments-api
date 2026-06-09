// swift-tools-version: 6.3
import PackageDescription

let package = Package(
  name: "Identity",
  platforms: [
    .iOS(.v26),
    .macOS(.v15),
  ],
  products: [
    .library(
      name: "Identity",
      targets: ["Identity"]
    )
  ],
  dependencies: [
    .package(name: "Gateway", path: "../../gateway/GatewayCore"),
    .package(name: "LeanSuiApi", path: "../../sui-api/LeanSuiApiCore"),
    .package(name: "Auth", path: "../../auth/AuthCore"),
  ],
  targets: [
    .target(
      name: "Identity",
      dependencies: [
        .product(name: "Gateway", package: "Gateway"),
        .product(name: "LeanSuiApi", package: "LeanSuiApi"),
        .product(name: "Auth", package: "Auth"),
      ],
      path: "Sources/Identity"
    ),
    .testTarget(
      name: "IdentityTests",
      dependencies: [
        "Identity",
        .product(name: "Gateway", package: "Gateway"),
        .product(name: "LeanSuiApi", package: "LeanSuiApi"),
        .product(name: "Auth", package: "Auth"),
      ],
      path: "Tests/IdentityTests"
    ),
  ]
)
