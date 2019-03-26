// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LoggingExample",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "LoggingExample",
            targets: ["LoggingExample"]),
        .executable(name: "App", targets: ["App"]),
        .executable(name: "Nike", targets: ["Nike"]),
        .executable(name: "OsLogging", targets: ["OsLogging"]),
        .executable(name: "S5", targets: ["S5"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", .branch("master")),
        .package(url: "https://github.com/Nike-Inc/Willow.git", from: Version(5, 0, 0)),
        .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", from: Version(1, 0, 0)),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "LoggingExample",
            dependencies: ["Logging"]),
        .target(name: "App", dependencies: ["Logging"]),
        .target(name: "OsLogging", dependencies: ["Logging"]),
        .target(name: "S5", dependencies: ["Logging", "SwiftyBeaver"]),
        .target(name: "Nike", dependencies: ["Logging", "Willow"]),
        .testTarget(
            name: "LoggingExampleTests",
            dependencies: ["LoggingExample"]),
    ]
)
