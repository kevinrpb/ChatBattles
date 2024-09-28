import SwiftGodot

public let godotTypes: [Wrapped.Type] = [
	GameScene.self,
	ShipCharacter.self,
]

#initSwiftExtension(cdecl: "swift_entry_point", types: godotTypes)
