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
        .package(path: "../../Packages/MagicKit"),
        .package(url: "https://github.com/nookery/MagicAlert.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "AudioScenePlugin",
            dependencies: [
                "CisumUI",
                .product(name: "MagicAlert", package: "MagicAlert"),
                .product(name: "MagicKit", package: "MagicKit")
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
