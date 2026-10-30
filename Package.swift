// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "StackedToasts",
    platforms: [.iOS(.v17)],
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
