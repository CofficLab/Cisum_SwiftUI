// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginOpenButton",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginOpenButton",
            targets: ["PluginOpenButton"]
        )
    ],
    dependencies: [
        .package(path: "../CisumUIComponents"),
        .package(path: "../KernelCore"),
        .package(name: "ProviderDocsView", path: "../ProviderDocsView"),
        .package(path: "../MagicPlayMan"),
    ],
    targets: [
        .target(
            name: "PluginOpenButton",
            dependencies: [
                .product(name: "CisumUIComponents", package: "CisumUIComponents"),
                .product(name: "KernelCore", package: "KernelCore"),
                .product(name: "ProviderDocsView", package: "ProviderDocsView"),
                .product(name: "MagicPlayMan", package: "MagicPlayMan"),
            ],
            path: ".",
            sources: ["Sources"],
            resources: [
                .process("Resources/Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "OpenButtonPluginTests",
            dependencies: ["PluginOpenButton"],
            path: "Tests"
        )
    ]
)
