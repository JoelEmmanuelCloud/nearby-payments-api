// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Hello",
    products: [
        .library(
            name: "Hello",
            targets: ["Hello"]
        ),
    ],
    targets: [
        .target(
            name: "Hello"
        ),
        .testTarget(
            name: "HelloTests",
            dependencies: ["Hello"]
        ),
    ]
)
