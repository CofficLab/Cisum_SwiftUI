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
            name: "StoreCore",
            targets: ["StoreCore"]
        ),
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
            name: "StoreCore",
            dependencies: [
                .product(name: "MagicKit", package: "MagicKit"),
                .product(name: "CisumUIComponents", package: "CisumUIComponents")
            ],
            path: ".",
            sources: [
                "Sources/DTO",
                "Sources/Models",
                "Sources/Services"
            ],
            resources: [
                .process("Resources/Localizable.xcstrings")
            ]
        ),
        .target(
            name: "PluginStore",
            dependencies: [
                "StoreCore",
                .product(name: "MagicKit", package: "MagicKit"),
                .product(name: "CisumUIComponents", package: "CisumUIComponents"),
                .product(name: "KernelCore", package: "KernelCore"),
                .product(name: "ProviderDocsView", package: "ProviderDocsView"),
                .product(name: "AudioLibraryCore", package: "PluginAudio"),
            ],
            path: ".",
            sources: [
                "Sources/StorePlugin.swift",
                "Sources/StoreCoreExports.swift",
                "Sources/Observers",
                "Sources/ViewModels",
                "Sources/Views"
            ],
            resources: [
                .process("Resources/Localizable.xcstrings"),
                .process("Resources/Products.storekit")
            ]
        ),
        .testTarget(
            name: "StorePluginTests",
            dependencies: [
                "PluginStore",
                "StoreCore"
            ],
            path: "Tests"
        )
    ]
)
