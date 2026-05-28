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
    targets: [
        .target(
            name: "PluginFileLog",
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
