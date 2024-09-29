import SwiftGodot

@Godot
public final class GameScene: Node2D {
	private var twitchManager = TwitchManager()

	public override func _ready() {
		Task {
			do {
				try await twitchManager.connect()
				try await twitchManager.join("kevinrpb")
			} catch {
				GD.pushError("IRC Error: \(error)")
			}
		}
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

	public func shootProjectile(
		from ship: ShipCharacter,
		direction: Vector2,
		type: TextureManager.LaserType,
		color: TextureManager.LaserColor
	) {
		let projectile = LaserProjectile.instantiate()

		projectile.shootingShip = ship
		projectile.type = type
		projectile.color = color
		projectile.position = ship.position
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
