import SwiftGodot

extension Vector2 {
	static func random(
		xRange: ClosedRange<Float> = -1...1,
		yRange: ClosedRange<Float> = -1...1
	) -> Self {
		let x = Float.random(in: xRange)
		let y = Float.random(in: yRange)

		return .init(x: x, y: y).normalized()
	}

	func wrapping(_ rect: Rect2, margin: Vector2 = .zero) -> Self {
		var newVector = Vector2(from: self)

		// Wrap horizontally
		if newVector.x < -1 * margin.x {
			newVector.x = rect.size.x + margin.x
		} else if newVector.x > (rect.size.x + margin.x) {
			newVector.x = -1 * margin.x
		}

		// Wrap vertically
		if newVector.y < -1 * margin.y {
			newVector.y = rect.size.y + margin.y
		} else if newVector.y > (rect.size.y + margin.y) {
			newVector.y = -1 * margin.y
		}

		return newVector
	}

	func isOutside(_ rect: Rect2, margin: Vector2 = .zero) -> Bool {
		if x < -1 * margin.x {
			return true
		} else if x > (rect.size.x + margin.x) {
			return true
		}

		if y < -1 * margin.y {
			return true
		} else if y > (rect.size.y + margin.y) {
			return true
		}

		return false
	}
}
