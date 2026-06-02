// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "AudioCopyPlugin",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
    ],
    products: [
        .library(
            name: "AudioCopyPlugin",
            targets: ["AudioCopyPlugin"]
        ),
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI"),
        .package(path: "../../Packages/MagicKit"),
        .package(path: "../AudioPlugin"),
        .package(path: "../StorePlugin"),
        .package(url: "https://github.com/nookery/MagicAlert.git", from: "1.0.1"),
    ],
    targets: [
        .target(
            name: "AudioCopyPlugin",
            dependencies: [
                "CisumUI",
                "MagicKit",
                "AudioPlugin",
                "StorePlugin",
                "MagicAlert",
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
