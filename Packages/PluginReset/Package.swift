// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginReset",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginReset",
            targets: ["PluginReset"]
        )
    ],
    dependencies: [
        .package(path: "../CisumUIComponents"),
        .package(path: "../KernelCore"),
        .package(name: "ProviderDocsView", path: "../ProviderDocsView"),
        .package(path: "../ProviderStorage"),
    ],
    targets: [
        .target(
            name: "PluginReset",
            dependencies: [
                "CisumUIComponents",
                "KernelCore",
                "ProviderDocsView",
                .product(name: "ProviderStorage", package: "ProviderStorage"),
            ],
            path: ".",
            sources: ["Sources"],
            resources: [
                .process("Resources/Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "ResetPluginTests",
            dependencies: ["PluginReset"],
            path: "Tests"
        )
    ]
)
