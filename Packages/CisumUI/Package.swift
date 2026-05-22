// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "CisumUI",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "CisumUI",
            targets: ["CisumUI"]
        )
    ],
    targets: [
        .target(
            name: "CisumUI",
            path: "Sources/CisumUI"
        ),
        .testTarget(
            name: "CisumUITests",
            dependencies: ["CisumUI"],
            path: "Tests/CisumUITests"
        )
    ]
)
