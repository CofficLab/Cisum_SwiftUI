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
        .package(name: "ProviderDocsView", path: "../ProviderDocsView"),
        .package(path: "../PluginAudio"),
        .package(path: "../PluginBook"),
        .package(path: "../PluginBookScene"),
        .package(path: "../PluginDevice"),
        .package(name: "ProviderPlayback", path: "../ProviderPlayback"),
        .package(path: "../ProviderScene"),
        .package(path: "../ProviderStorage"),
    ],
    targets: [
        .target(
            name: "PluginBookDBView",
            dependencies: [
                "CisumUIComponents",
                .product(name: "KernelCore", package: "KernelCore"),
                .product(name: "ProviderDocsView", package: "ProviderDocsView"),
                "PluginAudio",
                "PluginBook",
                "PluginBookScene",
                "PluginDevice",
                .product(name: "ProviderPlayback", package: "ProviderPlayback"),
                "ProviderScene",
                "ProviderStorage",
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
