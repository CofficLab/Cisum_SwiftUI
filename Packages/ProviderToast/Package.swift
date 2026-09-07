// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ProviderToast",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(name: "ProviderToast", targets: ["ProviderToast"]),
    ],
    targets: [
        .target(
            name: "ProviderToast",
            path: ".",
            exclude: ["Tests"],
            sources: ["Sources/ProviderToast"]
        ),
        .testTarget(
            name: "ProviderToastTests",
            dependencies: ["ProviderToast"],
            path: "Tests/ProviderToastTests"
        ),
    ],
    swiftLanguageModes: [.v5]
)
