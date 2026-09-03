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
        .package(path: "../CisumUIComponents"),
        .package(path: "../KernelCore"),
        .package(path: "../ProviderStorage"),
    ],
    targets: [
        .target(
            name: "PluginWelcome",
            dependencies: [
                "CisumUIComponents",
                .product(name: "KernelCore", package: "KernelCore"),
                .product(name: "ProviderStorage", package: "ProviderStorage"),
            ],
            path: ".",
            sources: ["Sources"],
            resources: [
                .process("Resources/Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "WelcomePluginTests",
            dependencies: ["PluginWelcome"],
            path: "Tests"
        )
    ]
)
