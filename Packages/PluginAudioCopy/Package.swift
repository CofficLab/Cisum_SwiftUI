// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "AudioCopyPlugin",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "AudioCopyPlugin",
            targets: ["AudioCopyPlugin"]
        ),
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI"),
        .package(path: "../AudioPlugin"),
        .package(path: "../StorePlugin"),
    ],
    targets: [
        .target(
            name: "AudioCopyPlugin",
            dependencies: [
                "CisumUI",
                "AudioPlugin",
                "StorePlugin",
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings"),
            ]
        ),
        .testTarget(
            name: "AudioCopyPluginTests",
            dependencies: ["AudioCopyPlugin"],
            path: "Tests"
        ),
    ]
)
