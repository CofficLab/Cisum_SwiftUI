// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "CisumKernel",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "CisumKernel",
            targets: ["CisumKernel"]
        ),
    ],
    dependencies: [
        .package(name: "CisumUI", path: "../CisumUI"),
        .package(name: "MagicKit", path: "../MagicKit"),
        .package(name: "MagicPlayMan", path: "../MagicPlayMan"),
    ],
    targets: [
        .target(
            name: "CisumKernel",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI"),
                .product(name: "MagicKit", package: "MagicKit"),
                .product(name: "MagicPlayMan", package: "MagicPlayMan"),
            ],
            path: "Sources/CisumKernel"
        ),
        .testTarget(
            name: "CisumKernelTests",
            dependencies: ["CisumKernel"],
            path: "Tests/CisumKernelTests"
        ),
    ],
    swiftLanguageModes: [.v5]
)
