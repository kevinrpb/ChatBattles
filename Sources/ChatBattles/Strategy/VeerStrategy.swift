import SwiftGodot

public struct VeerData {
	let veerAngle: Double
	let direction: Vector2
	let duration: Double
}

public protocol VeerStrategy {
	var name: String { get }

	init()
	func getVeerData(for ship: ShipCharacter, ships: [ShipCharacter]) -> VeerData
}

public struct VeerStrategies {
	static let allStrategies: [any VeerStrategy.Type] = [
		WeakestEnemyVeerStrategy.self,
		StrongestEnemyVeerStrategy.self,
	]

	static func random() -> any VeerStrategy {
		guard let strat = allStrategies.randomElement() else {
			fatalError("No strategies to choose from!")
		}

		return strat.init()
	}
}
