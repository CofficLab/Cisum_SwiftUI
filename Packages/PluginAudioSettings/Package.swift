// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AudioSettingsPlugin",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "AudioSettingsPlugin",
            targets: ["AudioSettingsPlugin"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI"),
        .package(path: "../AudioPlugin")
    ],
    targets: [
        .target(
            name: "AudioSettingsPlugin",
            dependencies: [
                "CisumUI",
                .product(name: "AudioPlugin", package: "AudioPlugin")
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "AudioSettingsPluginTests",
            dependencies: ["AudioSettingsPlugin"],
            path: "Tests"
        )
    ]
)
