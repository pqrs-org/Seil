#!/bin/sh
PATH=/bin:/sbin:/usr/bin:/usr/sbin; export PATH

basedir="/Applications/PCKeyboardHack"
kextfile=''
uname=`uname -r`
case "${uname%%.*}" in
    9)
        kextfile="$basedir/PCKeyboardHack.Leopard.kext"
        ;;
    8)
        kextfile="$basedir/PCKeyboardHack.Tiger.kext"
        ;;
esac

if [ "x$kextfile" == 'x' ]; then
    exit 1
fi

if [ $1 == 'unload' ]; then
    "$basedir/scripts/save.sh"
    kextunload "$kextfile"
else
    kextload "$kextfile"
    sleep 3 # wait for a while just after kextload.

    sysctl="$basedir/scripts/sysctl.sh"
    [ -f "$sysctl" ] && "$sysctl"

    "$basedir/scripts/save.sh"
fi

exit 0
