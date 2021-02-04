import PackageDescription

let package = Package(
    name: "NestedCloudKitCodable",
    platforms: [
        .macOS(.v10_13),
        .iOS(.v10),
        .tvOS(.v11),
        .watchOS(.v3),
    ],
    products: [
        .library(name: "NestedCloudKitCodable", targets: ["NestedCKCodable"])
    ],
    targets: [
        .target(name: "NestedCKCodable", path: "./Source")
    ]
)
