// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginDevice",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginDevice",
            targets: ["PluginDevice"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/DeviceData"),
        .package(path: "../../Packages/CisumUI")
    ],
    targets: [
        .target(
            name: "PluginDevice",
            dependencies: [
                .product(name: "CisumDeviceData", package: "DeviceData"),
                .product(name: "CisumUI", package: "CisumUI")
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "DevicePluginTests",
            dependencies: ["PluginDevice"],
            path: "Tests"
        )
    ]
)
