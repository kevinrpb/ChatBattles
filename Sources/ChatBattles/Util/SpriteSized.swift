import SwiftGodot

protocol SpriteSized {
	var sprite: Sprite2D? { get }
}

extension SpriteSized {
	var size: Vector2 {
		sprite?.texture?.getSize() ?? .zero
	}
}
