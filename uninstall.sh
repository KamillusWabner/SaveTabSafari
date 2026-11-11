#!/bin/bash
# Stops and removes SaveTabs. Saved tabs are kept unless you pass --purge.
set -euo pipefail

osascript -e 'quit app "SaveTabs"' >/dev/null 2>&1 || true
rm -rf /Applications/SaveTabs.app
echo "SaveTabs removed. Remove it from Login Items in System Settings if you added it there."

if [[ "${1:-}" == "--purge" ]]; then
  rm -rf "$HOME/Library/SaveTabs"
  echo "Saved tabs deleted."
else
  echo "Saved tabs kept in ~/Library/SaveTabs (run with --purge to delete them)."
fi
