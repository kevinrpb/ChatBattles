import SwiftGodot

protocol SpriteSized {
	var shipSprite: Sprite2D? { get }
}

extension SpriteSized {
	var size: Vector2 {
		shipSprite?.texture?.getSize() ?? .zero
	}
}
