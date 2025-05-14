// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EmpikFoto",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .executable(
            name: "EmpikFoto",
            targets: ["EmpikFoto"]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "EmpikFoto",
            dependencies: [],
            path: "EmpikFoto"
        ),
        .testTarget(
            name: "EmpikFotoTests",
            dependencies: ["EmpikFoto"],
            path: "EmpikFotoTests"
        )
    ]
)
