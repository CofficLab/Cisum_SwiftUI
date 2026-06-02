// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AudioDemoPlugin",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "AudioDemoPlugin",
            targets: ["AudioDemoPlugin"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI"),
        .package(path: "../AudioScenePlugin")
    ],
    targets: [
        .target(
            name: "AudioDemoPlugin",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI"),
                .product(name: "AudioScenePlugin", package: "AudioScenePlugin")
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "AudioDemoPluginTests",
            dependencies: ["AudioDemoPlugin"],
            path: "Tests"
        )
    ]
)
