import SwiftGodot

public final class TextureManager {
	public enum ShipType: Int, Equatable, CaseIterable {
		case one = 1
		case two = 2
		case three = 3
	}

	public enum ShipColor: String, Equatable, CaseIterable {
		case red
	}

	public enum ShipDamage: Int, Equatable, CaseIterable {
		case one = 1
		case two = 2
		case three = 3
	}

	public enum LaserType: Int, Equatable, CaseIterable {
		case one = 1
		case two = 2
		case three = 3
	}

	public enum LaserColor: String, Equatable, CaseIterable {
		case red
	}

	static var loadedTextures: [String: Texture2D] = [:]

	private static func loadTexture(from path: String) -> Texture2D {
		if let texture = loadedTextures[path] {
			return texture
		}

		let resourcePath = "res://Assets/\(path)"
		let resource = ResourceLoader.load(path: resourcePath)

		guard let texture = resource as? Texture2D else {
			fatalError("Could not load texture with path <\(path)>.")
		}

		loadedTextures[path] = texture
		return texture
	}
}

// MARK: Ships

private extension TextureManager {
	static let shipTexturePaths: [ShipType: [ShipColor: String]] = [
		.one: [
			.red: "Ships/playerShip1_red.png"
		],
		.two: [
			.red: "Ships/playerShip2_red.png"
		],
		.three: [
			.red: "Ships/playerShip3_red.png"
		]
	]

	static let shipDamageTexturePaths: [ShipType: [ShipDamage: String]] = [
		.one: [
			.one: "Damage/playerShip1_damage1.png",
			.two: "Damage/playerShip1_damage2.png",
			.three: "Damage/playerShip1_damage3.png",
		],
		.two: [
			.one: "Damage/playerShip2_damage1.png",
			.two: "Damage/playerShip2_damage2.png",
			.three: "Damage/playerShip2_damage3.png",
		],
		.three: [
			.one: "Damage/playerShip3_damage1.png",
			.two: "Damage/playerShip3_damage2.png",
			.three: "Damage/playerShip3_damage3.png",
		]
	]
}

public extension TextureManager {
	static func shipTexture(type: ShipType, color: ShipColor) -> Texture2D {
		let path = shipTexturePaths[type]![color]!

		return loadTexture(from: path)
	}

	static func shipDamageTexture(type: ShipType, damage: ShipDamage) -> Texture2D {
		let path = shipDamageTexturePaths[type]![damage]!

		return loadTexture(from: path)
	}
}

// MARK: Laser

private extension TextureManager {
	static let laserTexturePaths: [LaserType: [LaserColor: String]] = [
		.one: [
			.red: "Lasers/laserRed01.png"
		],
		.two: [
			.red: "Lasers/laserRed02.png"
		],
		.three: [
			.red: "Lasers/laserRed03.png"
		]
	]
}

public extension TextureManager {
	static func laserTexture(type: LaserType, color: LaserColor) -> Texture2D {
		let path = laserTexturePaths[type]![color]!

		return loadTexture(from: path)
	}
}
