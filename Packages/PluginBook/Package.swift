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
        .package(path: "../CisumUIComponents"),
        .package(path: "../CisumKernel"),
        .package(path: "../ProviderStorage"),
    ],
    targets: [
        .target(
            name: "PluginBook",
            dependencies: [
                .product(name: "CisumUIComponents", package: "CisumUIComponents"),
                .product(name: "CisumKernel", package: "CisumKernel"),
                .product(name: "ProviderStorage", package: "ProviderStorage"),
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
