import SwiftGodot

@Godot
public final class ShipCharacter: CharacterBody2D {
	#signal("onWillFree", arguments: ["displayName": String.self])

	private static let maxHealthPoints = 6

	private let type: TextureManager.ShipType = .random()
	private let color: TextureManager.ShipColor = .random()

	private var laserType: TextureManager.LaserType = .random()
	private var laserColor: TextureManager.LaserColor = .random()

	private var active: Bool = false

	private var direction: Vector2 = .random().normalized()
	private var speed: Double = 150

	private var targetDirection: Vector2 = .zero
	private var veerAngle: Double = .zero
	private var veerTime: Double = 0.5

	private var healthPoints = ShipCharacter.maxHealthPoints

	@SceneTree(path: "CollisionShape")
	var collisionShape: CollisionShape2D?

	@SceneTree(path: "ShipSprite")
	var shipSprite: Sprite2D?

	@SceneTree(path: "DamageSprite")
	var damageSprite: Sprite2D?

	@SceneTree(path: "HealthBar")
	var healthBar: ProgressBar?

	@SceneTree(path: "NameLabel")
	var nameLabel: Label?

	@SceneTree(path: "VeerTimer")
	var veerTimer: Timer?

	@SceneTree(path: "ShootTimer")
	var shootTimer: Timer?

	var gameScene: GameScene?
	var displayName: String! {
		didSet {
			nameLabel?.text = displayName
		}
	}

	public override func _ready() {
		shipSprite?.texture = TextureManager.shipTexture(type: type, color: color)

		updateHealth()

		rotate(to: direction.angle() + Double.pi / 2)
		targetDirection = direction

		veerTimer?.timeout.connect { [weak self] in
			guard let self else { return }

			self.startVeering()
			self.veerTimer?.waitTime = self.veerTime
			self.veerTimer?.start()
		}
		veerTimer?.start()

		shootTimer?.timeout.connect { [weak self] in
			guard let self, self.active else { return }

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

	public func activate() {
		active = true
	}

	public func deactivate() {
		active = false
	}

	public func handleHit() {
		healthPoints -= 1

		// TODO: explode or someth

		updateHealth()

		if healthPoints < 1 {
			disappear()
		}
	}

	public func destroy() {
		disappear()
	}

	public func showName() {
		nameLabel?.visible = true
	}

	public func hideName() {
		nameLabel?.visible = false
	}

	public func setDirection(to newDirection: Vector2) {
		direction = newDirection
		rotate(to: newDirection.angle() + Double.pi / 2)
	}

	private func move(delta: Double) {
		guard active else { return }

		let newPosition = position + direction * (delta * speed)
		position = newPosition.wrapping(viewportRect, margin: size)
	}

	private func veer(delta: Double) {
		guard active else { return }

		let ratio = delta / veerTime
		let angle = ratio * veerAngle

		let newDirection = direction.rotated(angle: angle)

		// Only rotate until we reach the target (allowing for slight overshoot)
		if direction.angleTo(newDirection).sign == veerAngle.sign {
			setDirection(to: newDirection)
		}
	}

	private func rotate(to newAngle: Double) {
		collisionShape?.rotation = newAngle
		shipSprite?.rotation = newAngle
		damageSprite?.rotation = newAngle
	}

	private func startVeering() {
		guard active, Bool.random() else {
			veerTime = Double.random(in: 0.5...2)
			return
		}

		veerAngle = Double.random(in: -1...1) * Double.pi / 2
		targetDirection = direction.rotated(angle: veerAngle)
		veerTime = Double.random(in: 0.5...5)
	}

	private func updateHealth() {
		let healthPercentage = 100 * Double(healthPoints) / Double(Self.maxHealthPoints)

		healthBar?.value = healthPercentage

		if healthPercentage <= 25 {
			damageSprite?.texture = TextureManager.shipDamageTexture(type: type, damage: .three)
		} else if healthPercentage <= 50 {
			damageSprite?.texture = TextureManager.shipDamageTexture(type: type, damage: .two)
		} else if healthPercentage <= 75 {
			damageSprite?.texture = TextureManager.shipDamageTexture(type: type, damage: .one)
		}
	}

	private func disappear() {
		veerTimer?.stop()
		shootTimer?.stop()

		// TODO: Play an explosion or smth

		let disappearTween = createTween()?
			.tweenProperty(
				object: self,
				property: "modulate:a",
				finalVal: Variant(0.0),
				duration: 0.1
			)?
			.setEase(.out)?
			.setTrans(.quad)

		disappearTween?.finished.connect {
			self.emit(signal: ShipCharacter.onWillFree, self.displayName)
			self.queueFree()
		}
	}
}

extension ShipCharacter: SpriteSized, WithinViewport {}

extension ShipCharacter: LoadableScene {
	static let path = "Scenes/Ship.tscn"
}
