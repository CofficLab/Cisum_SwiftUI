// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "BookDBViewPlugin",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
    ],
    products: [
        .library(
            name: "BookDBViewPlugin",
            targets: ["BookDBViewPlugin"]
        ),
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI"),
        .package(path: "../../Packages/MagicKit"),
        .package(path: "../AudioPlugin"),
        .package(path: "../BookPlugin"),
        .package(path: "../BookScenePlugin"),
        .package(path: "../DevicePlugin"),
        .package(path: "../../Packages/MagicPlayMan"),
        .package(url: "https://github.com/nookery/MagicAlert", from: "1.0.1"),
    ],
    targets: [
        .target(
            name: "BookDBViewPlugin",
            dependencies: [
                "CisumUI",
                "MagicKit",
                "AudioPlugin",
                "BookPlugin",
                "BookScenePlugin",
                "DevicePlugin",
                "MagicPlayMan",
                .product(name: "MagicAlert", package: "MagicAlert"),
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings"),
            ]
        ),
        .testTarget(
            name: "BookDBViewPluginTests",
            dependencies: ["BookDBViewPlugin"],
            path: "Tests"
        ),
    ]
)
