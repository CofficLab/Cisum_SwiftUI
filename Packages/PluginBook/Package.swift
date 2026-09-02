// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginBook",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginBook",
            targets: ["PluginBook"]
        )
    ],
    dependencies: [
        .package(path: "../CisumUI"),
        .package(path: "../CisumKernel"),
    ],
    targets: [
        .target(
            name: "PluginBook",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI"),
                .product(name: "CisumKernel", package: "CisumKernel"),
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "BookPluginTests",
            dependencies: ["PluginBook"],
            path: "Tests"
        )
    ]
)
