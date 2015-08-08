#!/bin/sh
PATH=/bin:/sbin:/usr/bin:/usr/sbin; export PATH

basedir='/Library/Application Support/org.pqrs/Seil'

# --------------------
uname=`uname -r`
case "${uname%%.*}" in
    13)
        kextfile="$basedir/Seil.10.9.signed.kext";
        ;;
    14)
        kextfile="$basedir/Seil.10.10.signed.kext"
        ;;
    15)
        kextfile="$basedir/Seil.10.11.signed.kext"
        ;;
esac

if [ "x$kextfile" == 'x' ]; then
    exit 1
fi

# --------------------
argument="$1"
[ -z "$argument" ] && argument=start
case "$argument" in
    start)
        echo "Starting Seil"
        kextload "$kextfile"
        ;;

    stop)
        echo "Stopping Seil"
        kextunload -b org.pqrs.driver.Seil
        ;;

    *)
        echo "Usage: $0 {start|stop}"
        ;;
esac

exit 0
