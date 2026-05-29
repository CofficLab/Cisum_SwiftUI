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
        .package(path: "../CisumUI"),
        .package(path: "../MagicKit"),
        .package(path: "../PluginAudio"),
        .package(path: "../PluginBook"),
        .package(path: "../PluginBookScene"),
        .package(path: "../PluginDevice"),
        .package(url: "https://github.com/nookery/MagicPlayMan", from: "1.3.5"),
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
