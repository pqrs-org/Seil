#!/bin/sh
PATH=/bin:/sbin:/usr/bin:/usr/sbin; export PATH

basedir="/Applications/PCKeyboardHack.app/Contents/Library"

argument="$1"
[ -z "$argument" ] && argument=start
case "$argument" in
    start)
        echo "Starting PCKeyboardHack"
        "$basedir/scripts/kext.sh"
        ;;

    stop)
        echo "Stopping PCKeyboardHack"
        "$basedir/scripts/kext.sh" unload
        ;;

    *)
        echo "Usage: $0 {start|stop}"
        ;;
esac

exit 0
