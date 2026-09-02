// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ThemeSettingsPlugin",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "ThemeSettingsPlugin",
            targets: ["ThemeSettingsPlugin"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI")
    ],
    targets: [
        .target(
            name: "ThemeSettingsPlugin",
            dependencies: ["CisumUI"],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "ThemeSettingsPluginTests",
            dependencies: ["ThemeSettingsPlugin"],
            path: "Tests"
        )
    ]
)
