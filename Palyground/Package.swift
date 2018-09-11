// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Palyground",
    products: [
        .executable(name: "Palyground", targets: ["Palyground"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "1.8.0"),
        .package(url: "https://github.com/apple/swift-nio-ssl.git", from: "1.1.1"),
        .package(url: "git@github.com:ReactiveX/RxSwift.git", from: "4.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Palyground",
            dependencies: ["NIO", "NIOHTTP1", "NIOOpenSSL", "RxSwift"]),
        .target(name:"HttpClient2", dependencies:["NIO","NIOOpenSSL","NIOHTTP1","RxSwift"]),
        .target(name:"RxPlay", dependencies:["RxSwift"]),
    ]
)
