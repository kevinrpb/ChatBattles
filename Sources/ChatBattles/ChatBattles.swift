import SwiftGodot

public let godotTypes: [Wrapped.Type] = [
	GameScene.self,
	ShipCharacter.self,
	LaserProjectile.self,
	SettingsMenu.self,
	TwitchManager.self,
]

#initSwiftExtension(cdecl: "swift_entry_point", types: godotTypes)
