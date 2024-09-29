import Foundation

extension CaseIterable {
	static func random() -> Self {
		allCases.randomElement()!
	}
}
