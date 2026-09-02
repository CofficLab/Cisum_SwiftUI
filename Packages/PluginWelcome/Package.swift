// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginWelcome",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginWelcome",
            targets: ["PluginWelcome"]
        )
    ],
    dependencies: [
        .package(path: "../CisumUI"),
        .package(path: "../CisumKernel"),
        .package(path: "../ProviderStorage"),
    ],
    targets: [
        .target(
            name: "PluginWelcome",
            dependencies: [
                "CisumUI",
                .product(name: "CisumKernel", package: "CisumKernel"),
                .product(name: "ProviderStorage", package: "ProviderStorage"),
            ],
            path: "Sources",
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "WelcomePluginTests",
            dependencies: ["PluginWelcome"],
            path: "Tests"
        )
    ]
)
