import SwiftGodot

struct RandomVeerStrategy: VeerStrategy {
	let name = "Random"

	func getVeerData(for ship: ShipCharacter, ships: [ShipCharacter]) -> VeerData {
		let veerAngle = Double.random(in: -1...1) * Double.pi / 2
		let targetDirection = ship.direction.rotated(angle: veerAngle)
		let veerTime = Double.random(in: 0.5...5)

		return .init(veerAngle: veerAngle, direction: targetDirection, duration: veerTime)
	}
}
