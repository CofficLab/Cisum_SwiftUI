// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AudioPlugin",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "AudioPlugin",
            targets: ["AudioPlugin"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI"),
        .package(path: "../../Packages/CisumKernel"),
        .package(path: "../AudioLikePlugin"),
    ],
    targets: [
        .target(
            name: "AudioPlugin",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI"),
                .product(name: "CisumKernel", package: "CisumKernel"),
                .product(name: "AudioLikePlugin", package: "AudioLikePlugin"),
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "AudioPluginTests",
            dependencies: ["AudioPlugin"],
            path: "Tests"
        )
    ]
)
