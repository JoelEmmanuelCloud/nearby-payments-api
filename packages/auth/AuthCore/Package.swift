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
      targets: ["Auth"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-crypto.git", "1.0.0"..<"4.0.0"),
    .package(url: "https://github.com/google/GoogleSignIn-iOS", from: "9.0.0"),
    .package(name: "Storage", path: "../../storage/StorageCore"),
    .package(name: "HSM", path: "../../hsm/HSMCore"),
    .package(name: "Gateway", path: "../../gateway/GatewayCore"),
    .package(name: "DeviceIntegrity", path: "../../device-integrity"),
  ],
  targets: [
    .target(
      name: "Auth",
      dependencies: [
        .product(name: "Crypto", package: "swift-crypto"),
        .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS"),
        .product(name: "Storage", package: "Storage"),
        .product(name: "HSM", package: "HSM"),
        .product(name: "Gateway", package: "Gateway"),
        .product(name: "DeviceIntegrity", package: "DeviceIntegrity"),
      ],
      path: "Sources/Auth",
      exclude: [
        "swift-java.config"
      ]
    )
  ]
)
