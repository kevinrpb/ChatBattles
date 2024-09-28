import SwiftGodot

@Godot
public final class GameScene: Node2D {
	public override func _ready() {
	}

	public override func _unhandledInput(event: InputEvent?) {
		guard
			let event = event as? InputEventMouseButton,
			event.pressed, !event.isEcho(), event.buttonIndex == .left
		else {
			return
		}

		addShip(in: viewportRect)
	}

	public func shootProjectile(from point: Vector2, direction: Vector2) {
		let projectile = LaserProjectile.instantiate()

		projectile.position = point
		projectile.direction = direction

		addChild(node: projectile)
		animateIn(projectile, duration: 0.2)
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

		ship.gameScene = self

		ship.position.x = position.x
		ship.position.y = position.y

		addChild(node: ship)

		if animate {
			animateIn(ship)
		}
	}

	private func animateIn(_ node: Node2D, duration: Double = 1.0) {
		node.modulate.alpha = 0

		let _ = node.createTween()?
			.tweenProperty(
				object: node, property: "modulate:a", finalVal: .init(1.0), duration: duration)?
			.setTrans(.quad)?
			.setEase(.in)
	}
}

extension GameScene: WithinViewport {}

extension GameScene: LoadableScene {
	static let path = "Scenes/GameScene.tscn"
}
