import SwiftGodot

@Godot
public final class GameScene: Node2D {
	private var viewport: Viewport? { getViewport() }

	public override func _ready() {
	}

	public override func _unhandledInput(event: InputEvent?) {
		guard
			let viewport,
			let event = event as? InputEventMouseButton,
			event.pressed, !event.isEcho(), event.buttonIndex == .left
		else {
			return
		}

		addShip(in: viewport.getVisibleRect())
	}

	private func addShips(_ n: Int, in rect: Rect2, animate: Bool = true) {
		for _ in 0..<n { addShip(in: rect, animate: animate) }
	}

	private func addShip(in rect: Rect2, animate: Bool = true) {
		let x = Float.random(in: 0...rect.size.x)
		let y = Float.random(in: 0...rect.size.y)

		addShip(at: Vector2(x: x, y: y), animate: animate)
	}

	private func addShip(at position: Vector2, animate: Bool = true) {
		let ship = ShipCharacter.instantiate()

		ship.position.x = position.x
		ship.position.y = position.y

		ship.modulate.alpha = animate ? 0 : 1

		addChild(node: ship)

		if animate {
			let _ = ship.createTween()?
				.tweenProperty(
					object: ship, property: "modulate:a", finalVal: .init(1.0), duration: 1.0)?
				.setTrans(.quad)?
				.setEase(.in)
		}
	}
}

extension GameScene: LoadableScene {
	static let path = "Scenes/GameScene.tscn"
}
