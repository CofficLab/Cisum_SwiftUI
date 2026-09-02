// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "CisumUIComponents",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "CisumUIComponents",
            targets: ["CisumUIComponents"]
        )
    ],
    dependencies: [
        .package(name: "MagicKit", path: "../MagicKit"),
        .package(name: "LumiUI", url: "https://github.com/CofficLab/LumiUI", from: "1.1.0"),
    ],
    targets: [
        .target(
            name: "CisumUIComponents",
            dependencies: [
                .product(name: "MagicKit", package: "MagicKit"),
                .product(name: "LumiUI", package: "LumiUI"),
            ],
            path: "Sources",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency=minimal"),
            ]
        )
    ],
    swiftLanguageModes: [.v5]
)
