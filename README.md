# ChatBattles


## Development

1. Build once with `swift build -c debug`.
2. Link the dylibs:
	- ``ln -s `pwd`/.build/debug/libSwiftGodot.dylib godot/bin/libSwiftGodot.dylib``
	- ``ln -s `pwd`/.build/debug/libChatBattles.dylib godot/bin/libChatBattles.dylib``
3. Open the project from Godot once so it loads the extension.
4. Run the game.
	- With Xcode:
		1. Build 
