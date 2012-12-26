#!/bin/sh

TMPDIR=`/usr/bin/mktemp -d /tmp/PCKeyboardHack_uninstaller.XXXXXX` || exit 1
/usr/bin/rsync -a /Applications/PCKeyboardHack.app/Contents/Applications/PCKeyboardHackUninstaller.app "$TMPDIR"
/Applications/PCKeyboardHack.app/Contents/Library/extra/setpermissions.sh "$TMPDIR/PCKeyboardHackUninstaller.app"
/usr/bin/open "$TMPDIR/PCKeyboardHackUninstaller.app"
