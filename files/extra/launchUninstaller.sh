#!/bin/sh

TMPDIR=`/usr/bin/mktemp -d /tmp/Seil_uninstaller.XXXXXX` || exit 1
/usr/bin/rsync -a /Applications/Seil.app/Contents/Applications/SeilUninstaller.app "$TMPDIR"
/Applications/Seil.app/Contents/Library/extra/setpermissions.sh "$TMPDIR/SeilUninstaller.app"
/usr/bin/open "$TMPDIR/SeilUninstaller.app"
