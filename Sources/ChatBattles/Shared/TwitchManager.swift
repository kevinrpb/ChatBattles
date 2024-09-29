import SwiftGodot
import Twitch
import TwitchIRC

final actor TwitchManager {
	private var ircClient: TwitchIRCClient?
	private var ircHandleTask: Task<Void, Error>? = nil

	var currentChannel: String?

	func connect() async throws {
		ircClient = try? await TwitchIRCClient(.anonymous)

		try await connectIRC()
	}

	func join(_ channel: String) async throws {
		guard let ircClient else {
			fatalError("IRC Client not set up")
		}

		if let currentChannel {
			try await ircClient.part(from: currentChannel)
		}

		try await ircClient.join(to: channel)
	}

	private func connectIRC() async throws {
		guard let ircClient else {
			fatalError("IRC Client not set up")
		}

		ircHandleTask?.cancel()
		ircHandleTask = Task {
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

	private func handleMessage(_ incomingMessage: IncomingMessage) async {
		switch incomingMessage {
		case let .join(join): handle(join)
		case let .privateMessage(privateMessage): await handle(privateMessage)
		default: break
		}
	}

	private func handle(_ join: Join) {
		GD.print("[\(join.channel)] Joined")
		currentChannel = join.channel
	}

	private func handle(_ privateMessage: PrivateMessage) async {
		GD.print(
			"[\(privateMessage.channel)] Got message from <\(privateMessage.displayName)>: \(privateMessage.message)"
		)
	}
}
