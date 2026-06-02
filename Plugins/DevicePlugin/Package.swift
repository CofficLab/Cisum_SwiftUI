// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "DevicePlugin",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "DevicePlugin",
            targets: ["DevicePlugin"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/DeviceData"),
        .package(path: "../../Packages/MagicKit")
    ],
    targets: [
        .target(
            name: "DevicePlugin",
            dependencies: [
                .product(name: "CisumDeviceData", package: "DeviceData"),
                .product(name: "MagicKit", package: "MagicKit")
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "DevicePluginTests",
            dependencies: ["DevicePlugin"],
            path: "Tests"
        )
    ]
)
