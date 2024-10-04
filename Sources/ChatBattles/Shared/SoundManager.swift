import SwiftGodot

public final class SoundManager {
	public enum LaserVariation: Int, Equatable, CaseIterable {
		case one = 1
		case two = 2
		case three = 3
		case fout = 4
		case five = 5
	}

	public enum ImpactVariation: Int, Equatable, CaseIterable {
		case one = 1
		case two = 2
		case three = 3
		case fout = 4
		case five = 5
		case six = 6
		case seven = 7
		case eight = 8
		case nine = 9
		case ten = 10
	}

	static var loadedAudios: [String: AudioStream] = [:]

	private static func loadAudio(from path: String) -> AudioStream {
		if let audio = loadedAudios[path] {
			return audio
		}

		var path = path
		if !path.hasSuffix(".ogg") {
			GD.pushWarning(
				"Forgot to add file extension to sound with path <\(path)>. Will use OGG.")
			path = "\(path).ogg"
		}

		let resourcePath = "res://Assets/\(path)"

		guard let audio = AudioStreamOggVorbis.loadFromFile(path: resourcePath) else {
			fatalError("Could not load texture with path <\(path)>.")
		}

		loadedAudios[path] = audio
		return audio
	}
}

extension SoundManager {
	public static func laserAudio(variation: LaserVariation) -> AudioStream {
		let number = String(format: "%03d", variation.rawValue - 1)
		let path = "Sounds/laserSmall_\(number).ogg"

		return loadAudio(from: path)
	}
}

extension SoundManager {
	public static func impactAudio(variation: ImpactVariation) -> AudioStream {
		let (name, number) =
			switch variation.rawValue {
			case 1...5: ("grass", String(format: "%03d", variation.rawValue - 1))
			case 6...10: ("snow", String(format: "%03d", variation.rawValue - 6))
			default: fatalError("Unhandled case")
			}

		let path = "Sounds/footstep_\(name)_\(number).ogg"

		return loadAudio(from: path)
	}
}
