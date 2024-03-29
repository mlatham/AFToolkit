// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AFToolkit",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "AFToolkit",
            targets: ["AFToolkit"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/SnapKit/SnapKit.git", from: "5.0.1"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.4.1"),
        .package(url: "https://github.com/ReSwift/ReSwift.git", from: "6.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "AFToolkit",
            dependencies: [
				"SnapKit",
				"Alamofire",
				"ReSwift",
            ],
            path: "Sources"),
        .testTarget(
            name: "AFToolkitTests",
            dependencies: ["AFToolkit"]),
    ]
)
