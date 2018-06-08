// swift-tools-version:4.0

import PackageDescription

let package = Package(
        name: "Hello-Rx",
        products: [
            .executable(name: "Hello-Rx", targets: ["Hello-Rx"]),
            .library(name: "Hello-Rx-Mod", targets: ["Hello-Rx-Mod"]),
            .executable(name: "Hello-Json", targets: ["Hello-Json"]),
        ],
        dependencies: [
            .package(url: "https://github.com/ReactiveX/RxSwift.git", "4.0.0"..<"5.0.0"),
        ],
        targets: [
            .target(
                    name: "Hello-Rx",
                    dependencies: ["RxSwift", "Hello-Rx-Mod"]),
            .target(name: "Hello-Rx-Mod", dependencies: ["RxSwift"]),
            .target(name: "Hello-Json", dependencies: []),
        ]
)
