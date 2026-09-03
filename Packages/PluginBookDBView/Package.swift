// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "PluginBookDBView",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "PluginBookDBView",
            targets: ["PluginBookDBView"]
        ),
    ],
    dependencies: [
        .package(path: "../CisumUIComponents"),
        .package(path: "../KernelCore"),
        .package(path: "../PluginAudio"),
        .package(path: "../PluginBook"),
        .package(path: "../PluginBookScene"),
        .package(path: "../PluginDevice"),
        .package(path: "../MagicPlayMan"),
        .package(path: "../ProviderScene"),
    ],
    targets: [
        .target(
            name: "PluginBookDBView",
            dependencies: [
                "CisumUIComponents",
                .product(name: "KernelCore", package: "KernelCore"),
                "PluginAudio",
                "PluginBook",
                "PluginBookScene",
                "PluginDevice",
                "MagicPlayMan",
                "ProviderScene",
            ],
            path: ".",
            sources: ["Sources"],
            resources: [
                .process("Resources/Localizable.xcstrings"),
            ]
        ),
        .testTarget(
            name: "BookDBViewPluginTests",
            dependencies: ["PluginBookDBView"],
            path: "Tests"
        ),
    ]
)
