// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AudioControlPlugin",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "AudioControlPlugin",
            targets: ["AudioControlPlugin"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI"),
        .package(path: "../AudioPlugin"),
        .package(path: "../AudioScenePlugin"),
        .package(path: "../../Packages/MagicPlayMan"),
    ],
    targets: [
        .target(
            name: "AudioControlPlugin",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI"),
                .product(name: "AudioPlugin", package: "AudioPlugin"),
                .product(name: "AudioScenePlugin", package: "AudioScenePlugin"),
                .product(name: "MagicPlayMan", package: "MagicPlayMan"),
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "AudioControlPluginTests",
            dependencies: ["AudioControlPlugin"],
            path: "Tests"
        )
    ]
)
