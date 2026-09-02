// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ProviderContentView",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(name: "ProviderContentView", targets: ["ProviderContentView"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ProviderContentView",
            dependencies: [],
            path: "Sources/ProviderContentView"
        ),
    ],
    swiftLanguageModes: [.v5]
)
