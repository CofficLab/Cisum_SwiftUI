// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AudioDBViewPlugin",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "AudioDBViewPlugin",
            targets: ["AudioDBViewPlugin"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI"),
        .package(path: "../../Packages/MagicKit"),
        .package(path: "../AudioPlugin"),
        .package(path: "../AudioScenePlugin"),
        .package(path: "../../Packages/MagicPlayMan"),
        .package(url: "https://github.com/nookery/MagicAlert", from: "1.0.1")
    ],
    targets: [
        .target(
            name: "AudioDBViewPlugin",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI"),
                .product(name: "MagicKit", package: "MagicKit"),
                .product(name: "AudioPlugin", package: "AudioPlugin"),
                .product(name: "AudioScenePlugin", package: "AudioScenePlugin"),
                .product(name: "MagicPlayMan", package: "MagicPlayMan"),
                .product(name: "MagicAlert", package: "MagicAlert")
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "AudioDBViewPluginTests",
            dependencies: ["AudioDBViewPlugin"],
            path: "Tests"
        )
    ]
)
