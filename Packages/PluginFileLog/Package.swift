// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginFileLog",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "PluginFileLog",
            targets: ["PluginFileLog"]
        )
    ],
    dependencies: [
        .package(path: "../CisumUI"),
    ],
    targets: [
        .target(
            name: "PluginFileLog",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI"),
            ],
            path: "Sources/PluginFileLog",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "PluginFileLogTests",
            dependencies: ["PluginFileLog"],
            path: "Tests/PluginFileLogTests"
        )
    ]
)
