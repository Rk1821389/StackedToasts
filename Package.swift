// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "StackedToasts",
    platforms: [.iOS("27.0")],
    products: [
        .library(name: "StackedToasts", targets: ["StackedToasts"])
    ],
    targets: [
        .target(
            name: "StackedToasts",
            swiftSettings: [.swiftLanguageMode(.v5)]
        )
    ]
)
