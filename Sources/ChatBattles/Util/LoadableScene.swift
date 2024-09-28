import SwiftGodot

protocol LoadableScene {
	static var path: String { get }
}

extension LoadableScene {
	static var packedScene: PackedScene? {
		GD.load(path: path) as? PackedScene
	}

	static func instantiate() -> Self {
		guard
			let packedScene,
			let node = packedScene.instantiate() as? Self
		else {
			fatalError("Could not instantiate <\(Self.self)> from path <\(path)>")
		}

		return node
	}
}
