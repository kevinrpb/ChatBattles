import SwiftGodot

@Godot
public final class ShipCharacter: CharacterBody2D {
	@SceneTree(path: "Sprite")
	var sprite: Sprite2D?

	var size: Vector2 {
		sprite?.texture?.getSize() ?? .zero
	}
}

extension ShipCharacter: LoadableScene {
	static let path = "Scenes/Ship.tscn"
}
