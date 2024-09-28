import SwiftGodot

@Godot
public final class LaserProjectile: Area2D {
	private var viewport: Viewport? { getViewport() }
	private var viewportRect: Rect2 {
		viewport?.getVisibleRect() ?? .init(x: 0, y: 0, width: 1920, height: 1080)
	}

	private var hasCollided: Bool = false
	private var disappearTween: Tweener?
	private var speed: Double = 600

	var shootingShip: ShipCharacter?
	var direction: Vector2 = .zero.normalized()

	@SceneTree(path: "Sprite")
	var sprite: Sprite2D?

	@SceneTree(path: "CollisionShape")
	var collisionShape: CollisionShape2D?

	var gameScene: GameScene?

	public override func _ready() {
		sprite?.rotation = direction.angle() + Double.pi / 2
	}

	public override func _physicsProcess(delta: Double) {
		position += direction * (delta * speed)

		if position.isOutside(viewportRect) {
			queueFree()
		}

		collide()
	}

	private func collide() {
		guard !hasCollided else { return }

		let colliding = getOverlappingBodies()
			.compactMap { $0 as? ShipCharacter }
			.filter { $0 != shootingShip }

		if let collider = colliding.first {
			hasCollided = true
			disappear()
			collider.handleHit()
		}
	}

	private func disappear() {
		guard disappearTween == nil else { return }

		disappearTween = createTween()?
			.tweenProperty(
				object: self,
				property: "modulate:a",
				finalVal: Variant(0.0),
				duration: 0.1
			)?
			.setEase(.out)?
			.setTrans(.quad)

		disappearTween?.finished.connect {
			self.queueFree()
		}
	}
}

extension LaserProjectile: SpriteSized {}

extension LaserProjectile: LoadableScene {
	static let path = "Scenes/LaserProjectile.tscn"
}
