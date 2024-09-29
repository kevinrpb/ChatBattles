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

	private static let maxShips = 20

	private var previousState: State = .initial
	private var currentState: State = .initial

	private var ships: [String: ShipCharacter] = [:]

	@SceneTree(path: "%SettingsButton")
	var settingsButton: Button?

	@SceneTree(path: "%SettingsMenu")
	var settingsMenu: SettingsMenu?

	@SceneTree(path: "%StartGameButton")
	var startGameButton: Button?

	@SceneTree(path: "%TwitchManager")
	var twitchManager: TwitchManager?

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
			// TODO: game!
		}

		uiTransition()
	}

	public override func _process(delta: Double) {
		if Input.isActionJustPressed(action: "settings_toggle") {
			toggleSettingsMenu()
		}

		guard previousState != currentState else {
			return
		}

		uiTransition()
		previousState = currentState
	}

	public override func _unhandledInput(event: InputEvent?) {
		guard
			let event = event as? InputEventMouseButton,
			event.pressed, !event.isEcho(), event.buttonIndex == .left
		else {
			return
		}

		addRandomShip(in: viewportRect)
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
	func onChatMessage(_ user: String, _ message: String) {
		GD.pushWarning("Message from \(user)")
	}

	@Callable
	func setState(_ stateValue: Int) {
		guard let state = State(rawValue: stateValue) else {
			fatalError("Tried to set state with value <\(stateValue)>, which is not recognized.")
		}

		currentState = state
	}

	@Callable
	func setupInitialShips() {
		for (_, ship) in ships {
			ship.destroy()
		}

		addRandomShips(16, in: viewportRect)
	}

	@Callable
	func onShipWillFree(_ displayName: String) {
		ships.removeValue(forKey: displayName)

		if ships.count < Self.maxShips {
			addRandomShips(Self.maxShips - ships.count, in: viewportRect)
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

			let _ = callDeferred(method: "setupInitialShips")

		// Chat
		case (_, .joiningChat):
			settingsMenu?.disable()
			startGameButton?.disabled = true
		case (.joiningChat, .joinedChat):
			let _ = callDeferred(method: "setState", Variant(State.idle.rawValue))
		case (_, .leavingChat):
			settingsMenu?.disable()
			startGameButton?.disabled = true
		case (.leavingChat, .leftChat):
			let _ = callDeferred(method: "setState", Variant(State.initial.rawValue))

		// Idle
		case (.joinedChat, .idle):
			settingsMenu?.enable()
			settingsMenu?.showDisconnect()
			startGameButton?.disabled = false

		// Unhandled, shouldn't happen
		default:
			fatalError("Unhandled state transition from <\(previousState)> to <\(currentState)>")
		}
	}

	private func addRandomShips(_ n: Int, in rect: Rect2, animate: Bool = true) {
		for _ in 0..<n { addRandomShip(in: rect, animate: animate) }
	}

	private func addRandomShip(in rect: Rect2, animate: Bool = true) {
		let x = Float.random(in: 0...rect.size.x)
		let y = Float.random(in: 0...rect.size.y)

		addShip(at: Vector2(x: x, y: y), activate: true, animate: animate)
	}

	private func addShip(
		at position: Vector2,
		with name: String? = nil,
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

		ships[ship.displayName] = ship
		ship.connect(signal: ShipCharacter.onWillFree, to: self, method: "onShipWillFree")

		addChild(node: ship)

		if animate { animateIn(ship) }
		if activate { ship.activate() }
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
