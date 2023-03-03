// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "swift-snapshot-testing-env-overlay",
    products: [
        .library(
            name: "SnapshotTestingEnvOverlay",
            targets: ["SnapshotTestingEnvOverlay"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-snapshot-testing.git",
            from: "1.11.0"
        ),
    ],
    targets: [
        .target(
            name: "SnapshotTestingEnvOverlay",
            dependencies: [
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ]
        ),
        .testTarget(
            name: "SnapshotTestingEnvOverlayTests",
            dependencies: ["SnapshotTestingEnvOverlay"]
        ),
    ]
)
