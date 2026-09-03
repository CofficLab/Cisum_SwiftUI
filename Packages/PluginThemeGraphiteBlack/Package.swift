// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginThemeGraphiteBlack",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginThemeGraphiteBlack",
            targets: ["PluginThemeGraphiteBlack"]
        )
    ],
    dependencies: [
        .package(path: "../CisumUIComponents"),
        .package(path: "../KernelCore"),
        .package(name: "ProviderDocsView", path: "../ProviderDocsView"),
    ],
    targets: [
        .target(
            name: "PluginThemeGraphiteBlack",
            dependencies: [
                .product(name: "CisumUIComponents", package: "CisumUIComponents"),
                .product(name: "KernelCore", package: "KernelCore"),
                .product(name: "ProviderDocsView", package: "ProviderDocsView"),
            ],
            path: ".",
            sources: ["Sources"],
            resources: [
                .process("Resources/Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "ThemeGraphiteBlackPluginTests",
            dependencies: ["PluginThemeGraphiteBlack"],
            path: "Tests"
        )
    ]
)
