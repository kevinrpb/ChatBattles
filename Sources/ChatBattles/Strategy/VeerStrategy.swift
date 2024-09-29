import SwiftGodot

public struct VeerData {
	let veerAngle: Double
	let direction: Vector2
	let duration: Double
}

public protocol VeerStrategy {
	func getVeerData(currentDirection: Vector2, ships: [ShipCharacter]) -> VeerData
}
