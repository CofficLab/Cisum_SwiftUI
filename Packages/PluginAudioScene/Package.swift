// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AudioScenePlugin",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "AudioScenePlugin",
            targets: ["AudioScenePlugin"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI"),
    ],
    targets: [
        .target(
            name: "AudioScenePlugin",
            dependencies: [
                "CisumUI",
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "AudioScenePluginTests",
            dependencies: ["AudioScenePlugin"],
            path: "Tests"
        )
    ]
)
