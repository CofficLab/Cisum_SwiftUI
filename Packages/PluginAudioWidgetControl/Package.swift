// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AudioWidgetControlPlugin",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "AudioWidgetControlPlugin",
            targets: ["AudioWidgetControlPlugin"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI"),
        .package(path: "../AudioPlugin"),
        .package(path: "../../Packages/MagicPlayMan"),
    ],
    targets: [
        .target(
            name: "AudioWidgetControlPlugin",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI"),
                .product(name: "AudioPlugin", package: "AudioPlugin"),
                .product(name: "MagicPlayMan", package: "MagicPlayMan"),
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "AudioWidgetControlPluginTests",
            dependencies: ["AudioWidgetControlPlugin"],
            path: "Tests"
        )
    ]
)
