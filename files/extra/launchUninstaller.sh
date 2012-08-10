#!/bin/sh

TMPDIR=`/usr/bin/mktemp -d /tmp/PCKeyboardHack_uninstaller.XXXXXX` || exit 1
/usr/bin/rsync -a /Library/org.pqrs/PCKeyboardHack/app/PCKeyboardHackUninstaller.app "$TMPDIR"
/Library/org.pqrs/PCKeyboardHack/extra/setpermissions.sh "$TMPDIR/PCKeyboardHackUninstaller.app"
/usr/bin/open "$TMPDIR/PCKeyboardHackUninstaller.app"
