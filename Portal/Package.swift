// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Portal",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "Portal", targets: ["Portal"])
    ],
    dependencies: [
        // 未来可能添加的依赖
        // .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "Portal",
            dependencies: [],
            path: "Portal/Sources",
            resources: [
                .process("../Resources")
            ]
        ),
        .testTarget(
            name: "PortalTests",
            dependencies: ["Portal"],
            path: "PortalTests"
        )
    ]
)
