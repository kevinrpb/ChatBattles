import SwiftGodot

@Godot
public final class GameScene: Node2D {

	@SceneTree(path: "%SettingsButton")
	var settingsButton: Button?

	@SceneTree(path: "%SettingsMenu")
	var settingsMenu: SettingsMenu?

	@SceneTree(path: "%StartGameButton")
	var startGameButton: Button?

	@SceneTree(path: "%TwitchManager")
	var twitchManager: TwitchManager?

	public override func _ready() {
		startGameButton?.disabled = true

		settingsButton?.pressed.connect {
			self.settingsButton?.releaseFocus()
			self.toggleSettingsMenu()
		}

		settingsMenu?.connect(signal: SettingsMenu.onClose, to: self, method: "onSettingsClose")
		settingsMenu?.connect(signal: SettingsMenu.onConnect, to: self, method: "onSettingsConnect")
		settingsMenu?.connect(signal: SettingsMenu.onDisconnect, to: self, method: "onSettingsDisconnect")

		twitchManager?.connect(signal: TwitchManager.onJoined, to: self, method: "onChatJoined")
		twitchManager?.connect(signal: TwitchManager.onParted, to: self, method: "onChatParted")
		twitchManager?.connect(signal: TwitchManager.onMessage, to: self, method: "onChatMessage")
	}

	public override func _process(delta: Double) {
		if Input.isActionJustPressed(action: "settings_toggle") {
			toggleSettingsMenu()
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

	@Callable
	func onSettingsClose() {
		toggleSettingsMenu()
	}

	@Callable
	func onSettingsConnect(_ channel: String) {
		settingsMenu?.disable()
		connectToChat(channel)
	}

	@Callable
	func onSettingsDisconnect() {
		settingsMenu?.disable()
		disconnectFromChat()
	}

	@Callable
	func onChatJoined(_ channel: String) {
		settingsMenu?.enable()
		settingsMenu?.showDisconnect()
		startGameButton?.disabled = false
	}

	@Callable
	func onChatParted(_ channel: String) {
		settingsMenu?.enable()
		settingsMenu?.showConnect()
		startGameButton?.disabled = true
	}

	@Callable
	func onChatMessage(_ user: String, _ message: String) {
		GD.pushWarning("Message from \(user)")
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

	private func toggleSettingsMenu() {
		if settingsMenu?.isVisibleInTree() ?? false {
			settingsMenu?.hide()
		} else {
			settingsMenu?.show()
		}
	}

	private func connectToChat(_ channel: String) {
		guard let twitchManager else {
			fatalError("Twitch manager not present")
		}

		GD.print("Connecting to <\(channel)>...")

		Task { @MainActor in
			do {
				try await twitchManager.connect()
				try await twitchManager.join(channel)
			} catch {
				GD.pushError("IRC Error: \(error)")
			}
		}
	}

	private func disconnectFromChat() {
		guard let twitchManager else {
			fatalError("Twitch manager not present")
		}

		GD.print("Disconnecting from <\(twitchManager.currentChannel ?? "?")>...")

		Task { @MainActor in
			do {
				try await twitchManager.connect()
				try await twitchManager.part()
			} catch {
				GD.pushError("IRC Error: \(error)")
			}
		}
	}
}

extension GameScene: WithinViewport {}

extension GameScene: LoadableScene {
	static let path = "Scenes/GameScene.tscn"
}
