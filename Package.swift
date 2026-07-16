// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "LinkGlint",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "LinkGlint", targets: ["LinkGlint"]),
        .executable(name: "LinkGlintHelper", targets: ["LinkGlintHelper"])
    ],
    targets: [
        .executableTarget(name: "LinkGlint"),
        .executableTarget(name: "LinkGlintHelper"),
        .testTarget(name: "LinkGlintTests", dependencies: ["LinkGlint"])
    ]
)
