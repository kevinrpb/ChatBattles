import SwiftGodot

public struct VeerData {
	let veerAngle: Double
	let direction: Vector2
	let duration: Double
}

extension VeerData {
	static func targetting(_ enemyShip: ShipCharacter, from ship: ShipCharacter) -> Self {
		// Try to veer to match the next shoot, add some 'reaction time'
		var veerTime = ship.shootTimer?.timeLeft ?? 0
		veerTime += Double.random(in: 0.1...0.4)

		// Estimate where the enemy will be in that time
		let targetPosition = enemyShip.position + enemyShip.direction * enemyShip.speed * veerTime

		// Calculate our veering to be pointing there when they arrive
		let veerAngle = ship.direction.angleToPoint(to: targetPosition)
		let targetDirection = ship.direction.rotated(angle: veerAngle)

		return .init(veerAngle: veerAngle, direction: targetDirection, duration: veerTime)
	}
}
