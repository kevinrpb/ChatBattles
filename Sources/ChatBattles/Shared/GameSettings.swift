import Foundation
import SwiftGodot

private struct GameSettingsData: Codable {
	var channel: String = ""
}

public class GameSettings {
	private static let instance: GameSettings = .init()

	private var data: GameSettingsData = .init()
	private var saveTask: Task<Void, Never>? = nil

	private init() {
		GD.print("Settings URL: \(Self.settingsURL?.absoluteString ?? "error")")

		data = Self.load()
	}

	private func deferSave() {
		saveTask?.cancel()
		saveTask = Task {
			try? await Task.sleep(for: .seconds(1))
			guard !Task.isCancelled else { return }

			GameSettings.save(data)
		}
	}
}

extension GameSettings {
	public static var channel: String {
		get {
			instance.data.channel
		}
		set {
			instance.data.channel = newValue
			instance.deferSave()
		}
	}
}

extension GameSettings {
	private static let settingsPath = "user://settings.json"
	private static let settingsGlobalPath = ProjectSettings.globalizePath(settingsPath)
	private static let settingsURL: URL? = .init(
		filePath: settingsGlobalPath, directoryHint: .notDirectory)

	private static let jsonDecoder: JSONDecoder = .init()
	private static let jsonEncoder: JSONEncoder = .init()

	fileprivate static func load() -> GameSettingsData {
		guard let settingsURL else {
			fatalError("Settings path URL was nil!")
		}

		guard FileManager.default.fileExists(atPath: settingsGlobalPath) else {
			let data: GameSettingsData = .init()
			save(data)

			return data
		}

		do {
			let jsonData: Data = try .init(contentsOf: settingsURL)
			let data = try jsonDecoder.decode(GameSettingsData.self, from: jsonData)

			return data
		} catch {
			GD.pushError("Error loading settings: \(error)")
			return .init()
		}
	}

	fileprivate static func save(_ data: GameSettingsData) {
		guard let settingsURL else {
			fatalError("Settings path URL was nil!")
		}

		do {
			let jsonData = try? jsonEncoder.encode(data)
			try jsonData?.write(to: settingsURL, options: [.atomic, .completeFileProtection])
		} catch {
			GD.pushError("Error saving settings: \(error)")
		}
	}
}
