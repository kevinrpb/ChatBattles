import SwiftGodot

final class RandomVeerStrategy: VeerStrategy {
	func getVeerData(currentDirection: Vector2, ships: [ShipCharacter]) -> VeerData {
		let veerAngle = Double.random(in: -1...1) * Double.pi / 2
		let targetDirection = currentDirection.rotated(angle: veerAngle)
		let veerTime = Double.random(in: 0.5...5)

		return .init(veerAngle: veerAngle, direction: targetDirection, duration: veerTime)
	}
}
