import SwiftGodot
import Twitch
import TwitchIRC

@Godot
final class TwitchManager: Node {
	private static let fakeChannel = "justinfan12345"

	#signal("on_joined", arguments: ["channel": String.self])
	#signal("on_parted", arguments: ["channel": String.self])
	#signal(
		"on_message",
		arguments: [
			"user": String.self,
			"message": String.self,
		])

	private var ircClient: TwitchIRCClient?
	private var ircHandleTask: Task<Void, Error>? = nil

	var currentChannel: String?

	@MainActor
	func connect() async throws {
		ircClient = try? await TwitchIRCClient(.anonymous)

		try await connectIRC()
		try await join(Self.fakeChannel) // This keeps the connection alive
	}

	@MainActor
	func join(_ channel: String) async throws {
		guard let ircClient else {
			fatalError("IRC Client not set up")
		}

		if let currentChannel {
			try await ircClient.part(from: currentChannel)
		}

		try await ircClient.join(to: channel)
	}

	@MainActor
	func part() async throws {
		guard let ircClient else {
			fatalError("IRC Client not set up")
		}

		guard let currentChannel else { return }

		try await ircClient.part(from: currentChannel)

		self.currentChannel = nil
		emit(signal: TwitchManager.onParted, currentChannel)
	}

	@MainActor
	private func connectIRC() async throws {
		guard let ircClient else {
			fatalError("IRC Client not set up")
		}

		ircHandleTask?.cancel()
		ircHandleTask = Task { @MainActor in
			do {
				for try await incomingMessage in await ircClient.stream() {
					await handleMessage(incomingMessage)
				}
			} catch {
				GD.pushError("IRC Error: \(error)")
				GD.pushError("IRC will try to reconnect")

				try await connectIRC()
			}
		}
	}

	@MainActor
	private func handleMessage(_ incomingMessage: IncomingMessage) async {
		switch incomingMessage {
		case let .join(join): handle(join)
		case let .part(part): handle(part)
		case let .privateMessage(privateMessage): await handle(privateMessage)
		default: break
		}
	}

	private func handle(_ join: Join) {
		GD.print("[\(join.channel)] Joined")
		guard join.channel != Self.fakeChannel else {
			return
		}

		currentChannel = join.channel

		emit(signal: TwitchManager.onJoined, join.channel)
	}

	private func handle(_ part: Part) {
		GD.print("[\(part.channel)] Parted")
		guard part.channel != Self.fakeChannel else {
			return
		}

		currentChannel = nil

		emit(signal: TwitchManager.onParted, part.channel)
	}

	@MainActor
	private func handle(_ privateMessage: PrivateMessage) async {
		GD.print(
			"[\(privateMessage.channel)] Got message from <\(privateMessage.displayName)>: \(privateMessage.message)"
		)

		emit(signal: TwitchManager.onMessage, privateMessage.displayName, privateMessage.message)
	}
}
