import SwiftGodot

public final class TextureManager {
	public enum ShipType: Int, Equatable, CaseIterable {
		case one = 1
	}

	public enum ShipColor: String, Equatable, CaseIterable {
		case red
	}

	public enum LaserType: Int, Equatable, CaseIterable {
		case one = 1
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
		]
	]
}

public extension TextureManager {
	static func shipTexture(type: ShipType, color: ShipColor) -> Texture2D {
		let path = shipTexturePaths[type]![color]!

		return loadTexture(from: path)
	}
}

// MARK: Laser

private extension TextureManager {
	static let laserTexturePaths: [LaserType: [LaserColor: String]] = [
		.one: [
			.red: "Lasers/laserRed01.png"
		]
	]
}

public extension TextureManager {
	static func laserTexture(type: LaserType, color: LaserColor) -> Texture2D {
		let path = laserTexturePaths[type]![color]!

		return loadTexture(from: path)
	}
}
