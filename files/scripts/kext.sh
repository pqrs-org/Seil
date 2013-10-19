#!/bin/sh
PATH=/bin:/sbin:/usr/bin:/usr/sbin; export PATH

basedir="/Applications/PCKeyboardHack.app/Contents/Library"
kextfile=''
uname=`uname -r`
case "${uname%%.*}" in
    12)
        kextfile="$basedir/PCKeyboardHack.10.8.kext"
        ;;
    13)
        kextfile="$basedir/PCKeyboardHack.10.9.signed.kext"
        ;;
esac

if [ "x$kextfile" == 'x' ]; then
    exit 1
fi

if [ "$1" == 'unload' ]; then
    kextunload -b org.pqrs.driver.PCKeyboardHack
else
    kextload "$kextfile"
fi

exit 0
