// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "swift-snapshot-testing-env",
    products: [
        .library(
            name: "SnapshotTestingEnv",
            targets: ["SnapshotTestingEnv"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-snapshot-testing.git",
            from: "1.11.0"
        ),
    ],
    targets: [
        .target(
            name: "SnapshotTestingEnv",
            dependencies: [
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ]
        ),
        .testTarget(
            name: "SnapshotTestingEnvTests",
            dependencies: ["SnapshotTestingEnv"]
        ),
    ]
)
