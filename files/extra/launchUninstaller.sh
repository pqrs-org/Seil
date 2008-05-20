#!/bin/sh

TMPDIR=`/usr/bin/mktemp -d /tmp/uninstaller.XXXXXX` || exit 1
/usr/bin/rsync -a /Library/org.pqrs/PCKeyboardHack/app/uninstaller.app "$TMPDIR"
/usr/bin/open "$TMPDIR/uninstaller.app"
