import Foundation
import SwiftGodot

@Godot
public final class GameScene: Node2D {
	enum State: Int {
		case initial
		case joiningChat
		case joinedChat
		case leavingChat
		case leftChat
		case idle
		case startingGame
		case playingGame
		case finishedGame
	}

	private static let maxPlayerShips = 20
	private static let maxRandomShips = 20
	private static let gameStartTime = 30.0

	private var previousState: State = .initial
	private var currentState: State = .initial

	private var ships: [String: ShipCharacter] = [:]

	@SceneTree(path: "%TwitchManager")
	var twitchManager: TwitchManager?

	@SceneTree(path: "%GameTimer")
	var gameStartTimer: SwiftGodot.Timer?

	@SceneTree(path: "%SettingsButton")
	var settingsButton: Button?

	@SceneTree(path: "%SettingsMenu")
	var settingsMenu: SettingsMenu?

	@SceneTree(path: "%StartGameButton")
	var startGameButton: Button?

	@SceneTree(path: "%GameTimerUI")
	var gameTimerUI: Control?

	@SceneTree(path: "%TimerLabel")
	var timerLabel: Label?

	public override func _ready() {
		settingsButton?.pressed.connect {
			self.settingsButton?.releaseFocus()
			self.toggleSettingsMenu()
		}

		settingsMenu?.connect(signal: SettingsMenu.onClose, to: self, method: "onSettingsClose")
		settingsMenu?.connect(signal: SettingsMenu.onConnect, to: self, method: "onSettingsConnect")
		settingsMenu?.connect(
			signal: SettingsMenu.onDisconnect, to: self, method: "onSettingsDisconnect")

		twitchManager?.connect(signal: TwitchManager.onJoined, to: self, method: "onChatJoined")
		twitchManager?.connect(signal: TwitchManager.onParted, to: self, method: "onChatParted")
		twitchManager?.connect(signal: TwitchManager.onMessage, to: self, method: "onChatMessage")

		startGameButton?.pressed.connect {
			self.setStateDeferred(.startingGame)
		}

		gameStartTimer?.waitTime = Self.gameStartTime
		gameStartTimer?.oneShot = true
		gameStartTimer?.timeout.connect {
			self.setStateDeferred(.playingGame)
		}

		uiTransition()
	}

	public override func _process(delta: Double) {
		if Input.isActionJustPressed(action: "settings_toggle") {
			toggleSettingsMenu()
		}

		if currentState == .startingGame {
			timerLabel?.text = "\(Int(gameStartTimer?.timeLeft ?? 0))s"
		}

		guard previousState != currentState else {
			return
		}

		uiTransition()
		previousState = currentState
	}

	public override func _unhandledInput(event: InputEvent?) {
		guard
			currentState == .startingGame,
			let event = event as? InputEventMouseButton,
			event.pressed,
			!event.isEcho(),
			event.buttonIndex == .left
		else {
			return
		}

		addShip(at: viewportRect.getCenter(), tint: "#aaa")
		repositionShipsInCircle()
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
		currentState = .joiningChat
		connectToChat(channel)
	}

	@Callable
	func onSettingsDisconnect() {
		currentState = .leavingChat
		disconnectFromChat()
	}

	@Callable
	func onChatJoined(_ channel: String) {
		currentState = .joinedChat
	}

	@Callable
	func onChatParted(_ channel: String) {
		currentState = .leftChat
	}

	@Callable
	func onChatMessage(
		_ displayName: String,
		_ message: String,
		_ colorHex: String
	) {
		guard
			currentState == .startingGame,
			let firstWord = message.split(separator: " ").first?.trimmingCharacters(
				in: .whitespaces),
			["!join", "join"].contains(firstWord),
			ships.count < Self.maxPlayerShips
		else { return }

		GD.pushWarning("Joining user <\(displayName)>")

		addShip(
			at: viewportRect.getCenter(),
			named: displayName,
			tint: colorHex.isEmpty ? nil : colorHex
		)
		repositionShipsInCircle()
	}

	@Callable
	func setState(_ stateValue: Int) {
		guard let state = State(rawValue: stateValue) else {
			fatalError("Tried to set state with value <\(stateValue)>, which is not recognized.")
		}

		currentState = state
	}

	@Callable
	func clearAllShips() {
		for (_, ship) in ships {
			ship.destroy()
		}
	}

	@Callable
	func setupRandomShips() {
		clearAllShips()
		addRandomShips(Self.maxRandomShips, in: viewportRect)
	}

	@Callable
	func onShipWillFree(_ displayName: String) {
		ships.removeValue(forKey: displayName)

		if currentState == .initial, ships.count < Self.maxRandomShips {
			addRandomShips(Self.maxRandomShips - ships.count, in: viewportRect)
		}
	}

	private func uiTransition() {
		GD.print("State transition from <\(previousState)> to <\(currentState)>")

		switch (previousState, currentState) {
		// Initial
		case (_, .initial):
			settingsMenu?.enable()
			settingsMenu?.showConnect()
			startGameButton?.disabled = true

			gameTimerUI?.visible = false

			let _ = callDeferred(method: "setupRandomShips")

		// Chat
		case (_, .joiningChat):
			settingsMenu?.disable()
			startGameButton?.disabled = true
		case (.joiningChat, .joinedChat):
			setStateDeferred(.idle)
		case (_, .leavingChat):
			settingsMenu?.disable()
			startGameButton?.disabled = true
		case (.leavingChat, .leftChat):
			setStateDeferred(.initial)

		// Idle
		case (.joinedChat, .idle):
			settingsMenu?.enable()
			settingsMenu?.showDisconnect()
			startGameButton?.disabled = false

		// Game start
		case (.idle, .startingGame):
			settingsMenu?.disable()
			startGameButton?.disabled = true

			gameTimerUI?.visible = true
			gameStartTimer?.start()

			let _ = callDeferred(method: "clearAllShips")

		// Unhandled, shouldn't happen
		default:
			fatalError("Unhandled state transition from <\(previousState)> to <\(currentState)>")
		}
	}

	private func setStateDeferred(_ state: State) {
		let _ = callDeferred(method: "setState", Variant(state.rawValue))
	}

	private func addRandomShips(_ n: Int, in rect: Rect2, animate: Bool = true) {
		for _ in 0..<n { addRandomShip(in: rect, animate: animate) }
	}

	private func addRandomShip(in rect: Rect2, animate: Bool = true) {
		let x = Float.random(in: 0...rect.size.x)
		let y = Float.random(in: 0...rect.size.y)

		addShip(
			at: Vector2(x: x, y: y),
			tint: "#aaa",
			activate: true,
			animate: animate
		)
	}

	private func addShip(
		at position: Vector2,
		named name: String? = nil,
		tint colorHex: String? = nil,
		activate: Bool = false,
		animate: Bool = true
	) {
		let ship = ShipCharacter.instantiate()

		ship.gameScene = self

		ship.position.x = position.x
		ship.position.y = position.y

		if let name {
			ship.displayName = name
			ship.showName()
		} else {
			ship.displayName = UUID().uuidString
			ship.hideName()
		}

		if let colorHex, !colorHex.trimmingCharacters(in: .whitespaces).isEmpty {
			// Get color from the hex value, but then attenuate its saturation
			var color = Color(code: colorHex, alpha: 0.1)
			color = Color.fromHsv(
				h: Double(color.hue), s: 0.5 * Double(color.saturation), v: Double(color.value))

			ship.modulate = color
		}

		ships[ship.displayName] = ship
		ship.connect(signal: ShipCharacter.onWillFree, to: self, method: "onShipWillFree")

		addChild(node: ship)

		if animate { animateIn(ship) }
		if activate { ship.activate() }
	}

	private func repositionShipsInCircle() {
		let center = viewportRect.getCenter()
		let radius = 400
		let angleDelta = 2 * Double.pi / Double(ships.count)

		var direction = Vector2(x: 0, y: -1).normalized()

		for (_, ship) in ships {
			ship.setDirection(to: direction)
			ship.position = center + direction * radius

			direction = direction.rotated(angle: angleDelta).normalized()
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
