import SwiftGodot

struct WeakestEnemyVeerStrategy: VeerStrategy {
	let name = "WeakestEnemy"

	func getVeerData(currentDirection: Vector2, ships: [ShipCharacter]) -> VeerData {
		let weakest = ships.min { shipA, shipB in
			shipA.healthPoints < shipB.healthPoints
		}

		guard let weakest else {
			fatalError("Veer strategy should only be called when there are enemies!")
		}

		// Randomize how long it will take us to veer
		let veerTime = Double.random(in: 0.2...0.6)

		// Estimate where the enemy will be in that time
		let targetPosition = weakest.position + weakest.direction * weakest.speed * veerTime

		// Calculate our veering to be pointing there when they arrive
		let veerAngle = currentDirection.angleToPoint(to: targetPosition)
		let targetDirection = currentDirection.rotated(angle: veerAngle)

		return .init(veerAngle: veerAngle, direction: targetDirection, duration: veerTime)
	}
}
