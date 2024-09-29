import SwiftGodot

@Godot
final class SettingsMenu: Control {
	#signal("on_close")
	#signal("on_connect", arguments: ["channel": String.self])
	#signal("on_disconnect")

	@SceneTree(path: "%ChannelText")
	var channelText: LineEdit?

	@SceneTree(path: "%ConnectButton")
	var connectButton: Button?

	@SceneTree(path: "%DisconnectButton")
	var disconnectButton: Button?

	@SceneTree(path: "%CloseButton")
	var closeButton: TextureButton?

	override func _ready() {
		showConnect()

		connectButton?.disabled = true

		channelText?.textChanged.connect { newText in
			self.connectButton?.disabled = newText.count < 3
		}

		closeButton?.pressed.connect {
			self.emit(signal: SettingsMenu.onClose)
		}

		connectButton?.pressed.connect {
			self.emit(signal: SettingsMenu.onConnect, self.channelText?.text ?? "")
		}

		disconnectButton?.pressed.connect {
			self.emit(signal: SettingsMenu.onDisconnect)
		}
	}

	public func enable() {
		channelText?.editable = true
		connectButton?.disabled = (channelText?.text.count ?? 0) < 3
		disconnectButton?.disabled = false
		closeButton?.disabled = false
	}

	public func disable() {
		channelText?.editable = false
		connectButton?.disabled = true
		disconnectButton?.disabled = true
		closeButton?.disabled = true
	}

	public func showConnect() {
		connectButton?.visible = true
		disconnectButton?.visible = false
	}

	public func showDisconnect() {
		connectButton?.visible = false
		disconnectButton?.visible = true
	}
}
