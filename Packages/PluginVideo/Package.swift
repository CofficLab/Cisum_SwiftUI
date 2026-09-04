// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginVideo",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginVideo",
            targets: ["PluginVideo"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUIComponents")
    ],
    targets: [
        .target(
            name: "PluginVideo",
            dependencies: [
                .product(name: "CisumUIComponents", package: "CisumUIComponents")
            ],
            path: ".",
            sources: ["Sources"],
            resources: [
                .process("Resources/Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "VideoPluginTests",
            dependencies: ["PluginVideo"],
            path: "Tests"
        )
    ]
)
