// swift-tools-version: 6.0

import PackageDescription

let package = Package(
	name: "ChatBattles",
	platforms: [.macOS(.v13)],
	products: [
		.library(
			name: "ChatBattles",
			type: .dynamic,
			targets: [
				"ChatBattles"
			]
		)
	],
	dependencies: [
		.package(
			url: "https://github.com/migueldeicaza/SwiftGodot",
			branch: "main"
		)
	],
	targets: [
		.target(
			name: "ChatBattles",
			dependencies: [
				.product(name: "SwiftGodot", package: "SwiftGodot")
			],
			swiftSettings: [
				.swiftLanguageMode(.v5)
			]
		)
	]
)
