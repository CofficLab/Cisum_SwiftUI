// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AudioJobPlugin",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "AudioJobPlugin",
            targets: ["AudioJobPlugin"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI"),
        .package(path: "../AudioPlugin"),
    ],
    targets: [
        .target(
            name: "AudioJobPlugin",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI"),
                .product(name: "AudioPlugin", package: "AudioPlugin"),
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "AudioJobPluginTests",
            dependencies: ["AudioJobPlugin"],
            path: "Tests"
        )
    ]
)
