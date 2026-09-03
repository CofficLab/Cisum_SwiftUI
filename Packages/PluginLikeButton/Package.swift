// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginLikeButton",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginLikeButton",
            targets: ["PluginLikeButton"]
        )
    ],
    dependencies: [
        .package(path: "../CisumUIComponents"),
        .package(path: "../KernelCore"),
        .package(path: "../MagicPlayMan"),
    ],
    targets: [
        .target(
            name: "PluginLikeButton",
            dependencies: [
                .product(name: "CisumUIComponents", package: "CisumUIComponents"),
                .product(name: "KernelCore", package: "KernelCore"),
                .product(name: "MagicPlayMan", package: "MagicPlayMan"),
            ],
            path: ".",
            sources: ["Sources"],
            resources: [
                .process("Resources/Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "LikeButtonPluginTests",
            dependencies: ["PluginLikeButton"],
            path: "Tests"
        )
    ]
)
