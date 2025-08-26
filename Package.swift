// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-dev-tools-mcp",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "swift-dev-tools-mcp", targets: ["swift-dev-tools-mcp"])
    ],
    dependencies: [
            .package(url: "https://github.com/modelcontextprotocol/swift-sdk", from: "0.7.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(name: "swift-dev-tools-mcp", dependencies: [
            .product(name: "MCP", package: "swift-sdk")
        ])
    ]
)
