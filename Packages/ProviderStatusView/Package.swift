// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ProviderStatusView",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(name: "ProviderStatusView", targets: ["ProviderStatusView"]),
    ],
    dependencies: [
        .package(name: "CisumKernel", path: "../CisumKernel"),
    ],
    targets: [
        .target(
            name: "ProviderStatusView",
            dependencies: [
                .product(name: "CisumKernel", package: "CisumKernel"),
            ],
            path: "Sources/ProviderStatusView"
        ),
    ],
    swiftLanguageModes: [.v5]
)
