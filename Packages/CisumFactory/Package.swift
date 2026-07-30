// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "CisumFactory",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "CisumFactory",
            targets: ["CisumFactory"]
        ),
    ],
    dependencies: [
        .package(name: "CisumKernel", path: "../CisumKernel"),
        .package(name: "MagicKit", path: "../MagicKit"),
    ],
    targets: [
        .target(
            name: "CisumFactory",
            dependencies: [
                .product(name: "CisumKernel", package: "CisumKernel"),
                .product(name: "MagicKit", package: "MagicKit"),
            ],
            path: "Sources/CisumFactory"
        ),
    ],
    swiftLanguageModes: [.v5]
)
