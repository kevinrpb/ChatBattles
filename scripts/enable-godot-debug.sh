#!/usr/bin/env sh

# This program will modify a Godot.app application to allow for debugging. It automates the
# procedure described in https://docs.godotengine.org/en/stable/contributing/development/debugging/macos_debug.html
# by using the $GODOT env variable, which should point to the Godot executable.

if [ "$(uname -s)" != "Darwin" ]; then
	echo "This program should only be run on macOS. Other systems do not need this procedure."
	echo "See: https://docs.godotengine.org/en/stable/contributing/development/debugging/macos_debug.html"
	exit -1
fi

if ! command -v /usr/libexec/PlistBuddy 2>&1 >/dev/null; then
	echo "PlistBuddy not present. It is needed to modify the entitlements."
	exit -1
fi

if [ -z "$GODOT" ]; then
	echo "GODOT env variable is not set. Please, point it to your Godot executable."
	exit -1
fi

# Find the Godot.app file by resolving from the executable.
# The executable should be placed at */Godot.app/Contents/MacOS/Godot.
# We use `readlink` to resolve any intermediary symlinks and the
# relative path.
GODOT_PATH=$(readlink -f $GODOT)
GODOT_APP_DIRPATH=$(readlink -f "${GODOT_PATH%/*}/../../..")
GODOT_APP_PATH=$(readlink -f "$GODOT_APP_DIRPATH/Godot.app")

if [ -z "$GODOT_APP_PATH" ]; then
	echo "Couldn't find Godot.app"
	echo "Searched in path <$GODOT_APP_DIRPATH> but it wasn't there"
	echo "GODOT_PATH was <$GODOT_PATH>"
	exit -1
fi

echo "Found Godot app at <$GODOT_APP_PATH>"

# Will use this temp folder
GODOT_TMP="/tmp/Godot"
rm -rf "$GODOT_TMP"
mkdir -p "$GODOT_TMP"

echo "Will work at <$GODOT_TMP>"

GODOT_TMP_APP="$GODOT_TMP/Godot.app"
GODOT_TMP_ENT="$GODOT_TMP/Godot.entitlements"

# Make a backup of Godot.app and copy it to temp
rm -rf "$GODOT_APP_PATH.bak"
cp -R "$GODOT_APP_PATH" "$GODOT_APP_PATH.bak"
cp -R "$GODOT_APP_PATH" "$GODOT_TMP"
echo "Made a backup of Godot app in <$GODOT_APP_PATH.bak>"

# Extract entitlements
codesign --display --xml --entitlements "$GODOT_TMP_ENT" "$GODOT_TMP_APP"
# Add get-task-allow
/usr/libexec/PlistBuddy -c 'add com.apple.security.get-task-allow bool true' "$GODOT_TMP_ENT"
# Readd entitlements
codesign -s - --deep --force --options=runtime --entitlements "$GODOT_TMP_ENT" "$GODOT_TMP_APP"

if [ $? -ne 0 ]; then
	echo "Error applying entitlements."
	exit -1
fi

# Copy the app back
cp -R "$GODOT_TMP_APP" "$GODOT_APP_DIRPATH"
