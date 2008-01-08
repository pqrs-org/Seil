#!/bin/sh
PATH=/bin:/sbin:/usr/bin:/usr/sbin; export PATH

# ----------------------------------------
# uninstall
basedir="/Applications/PCKeyboardHack"

"$basedir/scripts/unload.sh"
rm -f "/Library/LaunchDaemons/org.pqrs.PCKeyboardHack.load.plist"
rm -f "/Library/LaunchDaemons/org.pqrs.PCKeyboardHack.autosave.plist"
rm -rf "$basedir"

exit 0
