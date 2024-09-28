import SwiftGodot

@Godot
public final class ShipCharacter: CharacterBody2D {
	private var viewport: Viewport? { getViewport() }
	private var viewportRect: Rect2 {
		viewport?.getVisibleRect() ?? .init(x: 0, y: 0, width: 1920, height: 1080)
	}

	private var direction: Vector2 = .random().normalized()
	private var speed: Double = 150

	private var targetDirection: Vector2 = .zero
	private var veerAngle: Double = .zero
	private var veerTime: Double = 0.5

	@SceneTree(path: "Sprite")
	var sprite: Sprite2D?

	@SceneTree(path: "CollisionShape")
	var collisionShape: CollisionShape2D?

	@SceneTree(path: "Timer")
	var timer: Timer?

	var size: Vector2 {
		sprite?.texture?.getSize() ?? .zero
	}

	public override func _ready() {
		rotate(to: direction.angle() + Double.pi / 2)
		targetDirection = direction

		timer?.timeout.connect {
			self.startVeering()
			self.timer?.waitTime = self.veerTime
			self.timer?.start()
		}
		timer?.start()

		self.startVeering()
	}

	public override func _physicsProcess(delta: Double) {
		move(delta: delta)
		veer(delta: delta)
	}

	private func move(delta: Double) {
		let newPosition = position + direction * (delta * speed)
		position = newPosition.wrapping(viewportRect, margin: size)
	}

	private func veer(delta: Double) {
		let ratio = delta / veerTime
		let angle = ratio * veerAngle

		let newDirection = direction.rotated(angle: angle)

		// Only rotate until we reach the target (allowing for slight overshoot)
		if direction.angleTo(newDirection).sign == veerAngle.sign {
			direction = newDirection
			rotate(to: newDirection.angle() + Double.pi / 2)
		}
	}

	private func rotate(to newAngle: Double) {
		sprite?.rotation = newAngle
		collisionShape?.rotation = newAngle
	}

	private func startVeering() {
		guard Bool.random() else {
			veerTime = Double.random(in: 0.5...2)
			return
		}

		veerAngle = Double.random(in: -1...1) * Double.pi
		targetDirection = direction.rotated(angle: veerAngle)
		veerTime = Double.random(in: 0.5...5)
	}
}

extension ShipCharacter: LoadableScene {
	static let path = "Scenes/Ship.tscn"
}
