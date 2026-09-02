// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ProviderStorage",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    products: [
        .library(name: "ProviderStorage", targets: ["ProviderStorage"]),
    ],
    targets: [
        .target(name: "ProviderStorage", path: "Sources/ProviderStorage"),
    ],
    swiftLanguageModes: [.v5]
)
