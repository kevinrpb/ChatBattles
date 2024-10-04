import SwiftGodot

struct WeakestEnemyVeerStrategy: VeerStrategy {
	let name = "WeakestEnemy"

	func getVeerData(for ship: ShipCharacter, ships: [ShipCharacter]) -> VeerData {
		let weakest = ships.min { shipA, shipB in
			shipA.healthPoints < shipB.healthPoints
		}

		guard let weakest else {
			fatalError("Veer strategy should only be called when there are enemies!")
		}

		return .targetting(weakest, from: ship)
	}
}
