// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "StoragePlugin",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "StoragePlugin",
            targets: ["StoragePlugin"]
        ),
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI"),
        .package(path: "../../Packages/CisumKernel"),
        .package(path: "../../Packages/MagicKit"),
    ],
    targets: [
        .target(
            name: "StoragePlugin",
            dependencies: [
                "CisumUI",
                .product(name: "CisumKernel", package: "CisumKernel"),
                .product(name: "MagicKit", package: "MagicKit"),
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
