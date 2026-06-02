// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "StoragePlugin",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
    ],
    products: [
        .library(
            name: "StoragePlugin",
            targets: ["StoragePlugin"]
        ),
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI"),
        .package(path: "../../Packages/MagicKit"),
    ],
    targets: [
        .target(
            name: "StoragePlugin",
            dependencies: [
                "CisumUI",
                "MagicKit",
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings"),
            ]
        ),
        .testTarget(
            name: "StoragePluginTests",
            dependencies: ["StoragePlugin"],
            path: "Tests"
        ),
    ]
)
