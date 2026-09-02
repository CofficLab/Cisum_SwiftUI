// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginBookScene",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginBookScene",
            targets: ["PluginBookScene"]
        )
    ],
    dependencies: [
        .package(path: "../CisumUI"),
    ],
    targets: [
        .target(
            name: "PluginBookScene",
            dependencies: [
                "CisumUI",
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "BookScenePluginTests",
            dependencies: ["PluginBookScene"],
            path: "Tests"
        )
    ]
)
