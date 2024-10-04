import SwiftGodot

struct StrongestEnemyVeerStrategy: VeerStrategy {
	let name = "StrongestEnemy"

	func getVeerData(for ship: ShipCharacter, ships: [ShipCharacter]) -> VeerData {
		let strongest = ships.max { shipA, shipB in
			shipA.healthPoints < shipB.healthPoints
		}

		guard let strongest else {
			fatalError("Veer strategy should only be called when there are enemies!")
		}

		return .targetting(strongest, from: ship)
	}
}
