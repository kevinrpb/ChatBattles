import SwiftGodot

public let godotTypes: [Wrapped.Type] = [
	GameScene.self,
	ShipCharacter.self,
	LaserProjectile.self,
]

#initSwiftExtension(cdecl: "swift_entry_point", types: godotTypes)
