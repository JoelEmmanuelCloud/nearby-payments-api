// swift-tools-version: 6.3
import PackageDescription

let package = Package(
  name: "HSM",
  platforms: [
    .macOS(.v15),
    .iOS(.v26),
  ],
  products: [
    .library(
      name: "HSM",
      type: .dynamic,
      targets: ["HSM"]
    )
  ],
  dependencies: [
    .package(
      url: "https://github.com/vaariance/swift-java.git", branch: "peter/swift-java-callbackdeps")
  ],
  targets: [
    .target(
      name: "HSM",
      dependencies: [
        .product(name: "SwiftJava", package: "swift-java")
      ],
      path: "HSMCore/Sources/HSM",
      exclude: [
        "SecureEnclaveHSM.swift",
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
