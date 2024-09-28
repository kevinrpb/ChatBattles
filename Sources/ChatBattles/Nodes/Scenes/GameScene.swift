import SwiftGodot

@Godot
public final class GameScene: Node2D {
	private var viewport: Viewport? { getViewport() }

	public override func _ready() {
		guard let viewport else { fatalError("No viewport??") }

		addShip(in: viewport.getVisibleRect())
	}

	private func addShip(in rect: Rect2) {
		let ship = ShipCharacter.instantiate()

		addChild(node: ship)

		ship.position.x = rect.size.x / 2
		ship.position.y = rect.size.y / 2
	}
}

extension GameScene: LoadableScene {
	static let path = "Scenes/GameScene.tscn"
}
