// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AudioPlayModePlugin",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "AudioPlayModePlugin",
            targets: ["AudioPlayModePlugin"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI"),
        .package(path: "../AudioPlugin"),
        .package(path: "../AudioScenePlugin"),
        .package(path: "../../Packages/MagicKit"),
        .package(url: "https://github.com/nookery/MagicAlert.git", from: "1.0.0"),
        .package(path: "../../Packages/MagicPlayMan")
    ],
    targets: [
        .target(
            name: "AudioPlayModePlugin",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI"),
                .product(name: "AudioPlugin", package: "AudioPlugin"),
                .product(name: "AudioScenePlugin", package: "AudioScenePlugin"),
                .product(name: "MagicAlert", package: "MagicAlert"),
                .product(name: "MagicKit", package: "MagicKit"),
                .product(name: "MagicPlayMan", package: "MagicPlayMan")
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "AudioPlayModePluginTests",
            dependencies: ["AudioPlayModePlugin"],
            path: "Tests"
        )
    ]
)
