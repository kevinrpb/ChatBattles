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
		),
		.package(
			url: "https://github.com/LosFarmosCTL/swift-twitch-client",
			branch: "main"
		),
		.package(
			url: "https://github.com/MahdiBM/TwitchIRC",
			branch: "main"
		),
	],
	targets: [
		.target(
			name: "ChatBattles",
			dependencies: [
				.product(name: "SwiftGodot", package: "SwiftGodot"),
				.product(name: "Twitch", package: "swift-twitch-client"),
				.product(name: "TwitchIRC", package: "TwitchIRC"),
			],
			swiftSettings: [
				.swiftLanguageMode(.v5)
			]
		)
	]
)
