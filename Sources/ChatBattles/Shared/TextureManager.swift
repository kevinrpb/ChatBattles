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
		case red, green, blue
	}

	static var loadedTextures: [String: Texture2D] = [:]

	private static func loadTexture(from path: String) -> Texture2D {
		if let texture = loadedTextures[path] {
			return texture
		}

		var path = path
		if !path.hasSuffix(".png") {
			GD.pushWarning(
				"Forgot to add file extension to texture with path <\(path)>. Will use PNG.")
			path = "\(path).png"
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

extension TextureManager {
	public static func shipTexture(type: ShipType, color: ShipColor) -> Texture2D {
		let path = "Ships/playerShip\(type.rawValue)_\(color.rawValue).png"

		return loadTexture(from: path)
	}

	public static func shipDamageTexture(type: ShipType, damage: ShipDamage) -> Texture2D {
		let path = "Damage/playerShip\(type.rawValue)_damage\(damage.rawValue).png"

		return loadTexture(from: path)
	}
}

// MARK: Laser

extension TextureManager {
	public static func laserTexture(type: LaserType, color: LaserColor) -> Texture2D {
		let path =
			"Lasers/laser\(color.rawValue.capitalized)\(String(format: "%02d", type.rawValue)).png"

		return loadTexture(from: path)
	}
}
