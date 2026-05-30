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
        .package(path: "../../Packages/MagicKit")
    ],
    targets: [
        .target(
            name: "PluginDevice",
            dependencies: [
                .product(name: "CisumDeviceData", package: "DeviceData"),
                .product(name: "MagicKit", package: "MagicKit")
            ],
            path: "Sources/PluginDevice",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "PluginDeviceTests",
            dependencies: ["PluginDevice"],
            path: "Tests/PluginDeviceTests"
        )
    ]
)
