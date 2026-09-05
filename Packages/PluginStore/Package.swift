// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginStore",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginStore",
            targets: ["PluginStore"]
        )
    ],
    dependencies: [
        .package(path: "../MagicKit"),
        .package(path: "../CisumUIComponents"),
        .package(path: "../KernelCore"),
        .package(name: "ProviderDocsView", path: "../ProviderDocsView"),
        .package(path: "../PluginAudio"),
    ],
    targets: [
        .target(
            name: "PluginStore",
            dependencies: [
                .product(name: "MagicKit", package: "MagicKit"),
                .product(name: "CisumUIComponents", package: "CisumUIComponents"),
                .product(name: "KernelCore", package: "KernelCore"),
                .product(name: "ProviderDocsView", package: "ProviderDocsView"),
                .product(name: "PluginAudio", package: "PluginAudio"),
            ],
            path: ".",
            sources: ["Sources"],
            resources: [
                .process("Resources/Localizable.xcstrings"),
                .process("Resources/Products.storekit")
            ]
        ),
        .testTarget(
            name: "StorePluginTests",
            dependencies: ["PluginStore"],
            path: "Tests"
        )
    ]
)
