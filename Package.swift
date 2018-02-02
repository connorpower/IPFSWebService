// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "IPFSWebService",
    products: [
        .library(
            name: "IPFSWebService",
            targets: ["IPFSWebService"]),
    ],
    dependencies: [
         .package(url: "https://github.com/Alamofire/Alamofire.git", from: "4.0.0"),
         .package(url: "https://github.com/ReactiveX/RxSwift.git", "4.0.0" ..< "5.0.0")
    ],
    targets: [
        .target(
            name: "IPFSWebService",
          dependencies: ["Alamofire", "RxSwift"]),
        .testTarget(
            name: "IPFSWebServiceTests",
            dependencies: ["IPFSWebService"]),
    ]
)
