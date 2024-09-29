import SwiftGodot

@Godot
final class SettingsMenu: Control {
	#signal("on_close")
	#signal("on_connect", arguments: ["channel": String.self])

	@SceneTree(path: "%ChannelText")
	var channelText: LineEdit?

	@SceneTree(path: "%ConnectButton")
	var connectButton: Button?

	@SceneTree(path: "%CloseButton")
	var closeButton: TextureButton?

	override func _ready() {
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
	}

	public func enable() {
		channelText?.editable = true
		connectButton?.disabled = false
		closeButton?.disabled = false
	}

	public func disable() {
		channelText?.editable = false
		connectButton?.disabled = true
		closeButton?.disabled = true
	}
}
