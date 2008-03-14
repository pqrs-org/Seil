#!/bin/sh
PATH=/bin:/sbin:/usr/bin:/usr/sbin; export PATH

# ----------------------------------------
# uninstall
basedir="/Applications/PCKeyboardHack"
if [ -d $basedir ]; then
    "$basedir/scripts/unload.sh"
    rm -rf "$basedir"
fi

basedir="/Library/org.pqrs/PCKeyboardHack"
if [ -d $basedir ]; then
    "$basedir/scripts/unload.sh"
    rm -rf "$basedir"
fi

rm -f "/Library/LaunchDaemons/org.pqrs.PCKeyboardHack.load.plist"
rm -f "/Library/LaunchDaemons/org.pqrs.PCKeyboardHack.autosave.plist"
rm -rf "/Library/PreferencePanes/PCKeyboardHack.prefPane"

exit 0
