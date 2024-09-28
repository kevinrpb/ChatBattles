import SwiftGodot

@Godot
public final class LaserProjectile: Area2D {
	private var viewport: Viewport? { getViewport() }
	private var viewportRect: Rect2 {
		viewport?.getVisibleRect() ?? .init(x: 0, y: 0, width: 1920, height: 1080)
	}

	var direction: Vector2 = .zero.normalized()
	private var speed: Double = 600

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
	}
}

extension LaserProjectile: SpriteSized {}

extension LaserProjectile: LoadableScene {
	static let path = "Scenes/LaserProjectile.tscn"
}
