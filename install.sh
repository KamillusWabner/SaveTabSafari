#!/bin/bash
# Builds SaveTabs.app from source, installs it to /Applications and starts it.
set -euo pipefail
cd "$(dirname "$0")"

APP=SaveTabs.app
DEST=/Applications/SaveTabs.app

echo "Building $APP ..."
rm -rf "$APP"
osacompile -s -o "$APP" SaveTabs.applescript
PLIST="$APP/Contents/Info.plist"
plutil -replace LSUIElement -bool true "$PLIST"                     # no Dock icon
plutil -replace CFBundleIdentifier -string io.github.savetabs "$PLIST"
plutil -replace CFBundleName -string SaveTabs "$PLIST"
plutil -replace NSAppleEventsUsageDescription \
  -string "SaveTabs remembers the tabs of your Safari windows and restores them." "$PLIST"
codesign --force --deep -s - "$APP" >/dev/null 2>&1

echo "Installing to $DEST ..."
osascript -e 'quit app "SaveTabs"' >/dev/null 2>&1 || true
sleep 1
rm -rf "$DEST"
cp -R "$APP" "$DEST"
rm -rf "$APP"

open -g "$DEST"
echo
echo "Done. SaveTabs is running in the background."
echo "Allow it to control Safari when macOS asks."
echo "To start it automatically: System Settings > General > Login Items > + > SaveTabs"
