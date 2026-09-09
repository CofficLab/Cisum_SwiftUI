// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginBook",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "ProviderBook",
            targets: ["ProviderBook"]
        ),
        .library(
            name: "PluginBook",
            targets: ["PluginBook"]
        )
    ],
    dependencies: [
        .package(path: "../MagicKit"),
        .package(path: "../CisumUIComponents"),
        .package(path: "../KernelCore"),
        .package(name: "ProviderDocsView", path: "../ProviderDocsView"),
        .package(path: "../ProviderStorage"),
    ],
    targets: [
        .target(
            name: "ProviderBook",
            dependencies: [
                .product(name: "MagicKit", package: "MagicKit"),
                .product(name: "CisumUIComponents", package: "CisumUIComponents"),
            ],
            path: ".",
    sources: [
                    "Sources/BookProviding.swift",
                    "Sources/BookConfig.swift",
                "Sources/BookEvent.swift",
                "Sources/BookPluginError.swift",
                "Sources/BookPluginHost.swift",
                "Sources/BookPluginInfo.swift",
                "Sources/DB",
                "Sources/DTO",
                "Sources/Models",
                "Sources/Repo",
            ],
            resources: [
                .process("Resources/Localizable.xcstrings")
            ]
        ),
        .target(
            name: "PluginBook",
            dependencies: [
                "ProviderBook",
                .product(name: "MagicKit", package: "MagicKit"),
                .product(name: "CisumUIComponents", package: "CisumUIComponents"),
                .product(name: "KernelCore", package: "KernelCore"),
                .product(name: "ProviderDocsView", package: "ProviderDocsView"),
                .product(name: "ProviderStorage", package: "ProviderStorage"),
            ],
            path: ".",
            sources: [
                "Sources/BookPlugin.swift",
                "Sources/Observers",
                "Sources/ViewModels",
                "Sources/Views",
                "Sources/ProviderExports.swift",
            ],
            resources: [
                .process("Resources/Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "BookPluginTests",
            dependencies: ["PluginBook", "ProviderBook"],
            path: "Tests"
        )
    ]
)
