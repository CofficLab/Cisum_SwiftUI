// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "PluginBookDBView",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
    ],
    products: [
        .library(
            name: "PluginBookDBView",
            targets: ["PluginBookDBView"]
        ),
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI"),
        .package(path: "../../Packages/MagicKit"),
        .package(path: "../PluginAudio"),
        .package(path: "../PluginBook"),
        .package(path: "../PluginBookScene"),
        .package(path: "../PluginDevice"),
        .package(path: "../../Packages/MagicPlayMan"),
        .package(url: "https://github.com/nookery/MagicAlert", from: "1.0.1"),
    ],
    targets: [
        .target(
            name: "PluginBookDBView",
            dependencies: [
                "CisumUI",
                "MagicKit",
                "PluginAudio",
                "PluginBook",
                "PluginBookScene",
                "PluginDevice",
                "MagicPlayMan",
                .product(name: "MagicAlert", package: "MagicAlert"),
            ],
            resources: [
                .process("Resources/Book-DBView.xcstrings"),
            ]
        ),
        .testTarget(
            name: "PluginBookDBViewTests",
            dependencies: ["PluginBookDBView"]
        ),
    ]
)
