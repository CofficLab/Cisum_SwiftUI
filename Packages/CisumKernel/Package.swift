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
        // MARK: - Provider Contracts（能力契约独立成包，与 Lumi 的 Provider* 体系对齐）
        .package(name: "ProviderAppState", path: "../ProviderAppState"),
        .package(name: "ProviderAudioLibrary", path: "../ProviderAudioLibrary"),
        .package(name: "ProviderCloud", path: "../ProviderCloud"),
        .package(name: "ProviderDevice", path: "../ProviderDevice"),
        .package(name: "ProviderPlayback", path: "../ProviderPlayback"),
        .package(name: "ProviderPlugin", path: "../ProviderPlugin"),
        .package(name: "ProviderStorage", path: "../ProviderStorage"),
        .package(name: "ProviderTheme", path: "../ProviderTheme"),
    ],
    targets: [
        .target(
            name: "CisumKernel",
            dependencies: [
                .product(name: "CisumUI", package: "CisumUI"),
                .product(name: "MagicKit", package: "MagicKit"),
                .product(name: "MagicPlayMan", package: "MagicPlayMan"),
                .product(name: "ProviderAppState", package: "ProviderAppState"),
                .product(name: "ProviderAudioLibrary", package: "ProviderAudioLibrary"),
                .product(name: "ProviderCloud", package: "ProviderCloud"),
                .product(name: "ProviderDevice", package: "ProviderDevice"),
                .product(name: "ProviderPlayback", package: "ProviderPlayback"),
                .product(name: "ProviderPlugin", package: "ProviderPlugin"),
                .product(name: "ProviderStorage", package: "ProviderStorage"),
                .product(name: "ProviderTheme", package: "ProviderTheme"),
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
