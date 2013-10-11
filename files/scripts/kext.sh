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
        # Experimental: Use 10.8 kext on OS X 10.9 until source code of IOHIDFamily is released from Apple.
        kextfile="$basedir/PCKeyboardHack.10.8.kext"
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
