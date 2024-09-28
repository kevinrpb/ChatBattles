import SwiftGodot

@Godot
public final class ShipCharacter: CharacterBody2D {
}

extension ShipCharacter: LoadableScene {
	static let path = "Scenes/Ship.tscn"
}
