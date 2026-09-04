// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginThemeSettings",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginThemeSettings",
            targets: ["PluginThemeSettings"]
        )
    ],
    dependencies: [
        .package(path: "../CisumUIComponents"),
        .package(path: "../KernelCore"),
        .package(name: "ProviderDocsView", path: "../ProviderDocsView"),
        .package(path: "../ProviderTheme"),
    ],
    targets: [
        .target(
            name: "PluginThemeSettings",
            dependencies: ["CisumUIComponents", "KernelCore", "ProviderDocsView", "ProviderTheme"],
            path: ".",
            sources: ["Sources"],
            resources: [
                .process("Resources/Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "ThemeSettingsPluginTests",
            dependencies: ["PluginThemeSettings"],
            path: "Tests"
        )
    ]
)
