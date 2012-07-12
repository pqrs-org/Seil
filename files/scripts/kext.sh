#!/bin/sh
PATH=/bin:/sbin:/usr/bin:/usr/sbin; export PATH

basedir="/Library/org.pqrs/PCKeyboardHack"
kextfile=''
uname=`uname -r`
case "${uname%%.*}" in
    10)
        kextfile="$basedir/PCKeyboardHack.10.6.kext"
        ;;
    11)
        kextfile="$basedir/PCKeyboardHack.10.7.kext"
        ;;
    12)
        kextfile="$basedir/PCKeyboardHack.10.7.kext" # Temporary fix to allow 10.8 to use 10.7's kext
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
