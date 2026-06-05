// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "BookDBViewPlugin",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "BookDBViewPlugin",
            targets: ["BookDBViewPlugin"]
        ),
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI"),
        .package(path: "../AudioPlugin"),
        .package(path: "../BookPlugin"),
        .package(path: "../BookScenePlugin"),
        .package(path: "../DevicePlugin"),
        .package(path: "../../Packages/MagicPlayMan"),
    ],
    targets: [
        .target(
            name: "BookDBViewPlugin",
            dependencies: [
                "CisumUI",
                "AudioPlugin",
                "BookPlugin",
                "BookScenePlugin",
                "DevicePlugin",
                "MagicPlayMan",
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
