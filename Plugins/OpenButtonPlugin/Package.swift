// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "OpenButtonPlugin",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "OpenButtonPlugin",
            targets: ["OpenButtonPlugin"]
        )
    ],
    dependencies: [
        .package(path: "../../Packages/CisumUI"),
        .package(path: "../../Packages/MagicPlayMan"),
    ],
    targets: [
        .target(
            name: "OpenButtonPlugin",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI"),
                .product(name: "MagicPlayMan", package: "MagicPlayMan"),
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "OpenButtonPluginTests",
            dependencies: ["OpenButtonPlugin"],
            path: "Tests"
        )
    ]
)
