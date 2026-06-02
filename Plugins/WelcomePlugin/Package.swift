// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "WelcomePlugin",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "WelcomePlugin",
            targets: ["WelcomePlugin"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI"),
        .package(path: "../../Packages/MagicKit")
    ],
    targets: [
        .target(
            name: "WelcomePlugin",
            dependencies: [
                "CisumUI",
                .product(name: "MagicKit", package: "MagicKit")
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "WelcomePluginTests",
            dependencies: ["WelcomePlugin"],
            path: "Tests"
        )
    ]
)
