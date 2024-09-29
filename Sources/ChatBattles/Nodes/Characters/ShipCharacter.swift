import SwiftGodot

@Godot
public final class ShipCharacter: CharacterBody2D {
	private let type: TextureManager.ShipType = .random()
	private let color: TextureManager.ShipColor = .random()

	private var laserType: TextureManager.LaserType = .random()
	private var laserColor: TextureManager.LaserColor = .random()

	private var direction: Vector2 = .random().normalized()
	private var speed: Double = 150

	private var targetDirection: Vector2 = .zero
	private var veerAngle: Double = .zero
	private var veerTime: Double = 0.5

	@SceneTree(path: "Sprite")
	var sprite: Sprite2D?

	@SceneTree(path: "CollisionShape")
	var collisionShape: CollisionShape2D?

	@SceneTree(path: "VeerTimer")
	var veerTimer: Timer?

	@SceneTree(path: "ShootTimer")
	var shootTimer: Timer?

	var gameScene: GameScene?

	public override func _ready() {
		sprite?.texture = TextureManager.shipTexture(type: type, color: color)

		rotate(to: direction.angle() + Double.pi / 2)
		targetDirection = direction

		veerTimer?.timeout.connect { [weak self] in
			guard let self else { return }

			self.startVeering()
			self.veerTimer?.waitTime = self.veerTime
			self.veerTimer?.start()
		}
		veerTimer?.start()
		self.startVeering()

		shootTimer?.timeout.connect { [weak self] in
			guard let self else { return }

			self.gameScene?.shootProjectile(
				from: self,
				direction: self.direction,
				type: laserType,
				color: laserColor
			)
		}
		shootTimer?.start()
	}

	public override func _physicsProcess(delta: Double) {
		move(delta: delta)
		veer(delta: delta)
	}

	public func handleHit() {
		// TODO: Handle it
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

extension ShipCharacter: SpriteSized, WithinViewport {}

extension ShipCharacter: LoadableScene {
	static let path = "Scenes/Ship.tscn"
}
