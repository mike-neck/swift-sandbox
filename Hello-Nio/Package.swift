// swift-tools-version:4.0

import PackageDescription

let package = Package(
        name: "Hello-Nio",
        products: [
            .executable(name: "Hello-Nio", targets: ["Hello-Nio"])
        ],
        dependencies: [
            .package(url: "https://github.com/apple/swift-nio.git", from: "1.7.2")
        ],
        targets: [
            .target(name: "Hello-Nio", dependencies: ["NIO"]),
            .testTarget(name: "Hello-Nio-Tests", dependencies: ["NIO", "Hello-Nio"]),
        ]
)
