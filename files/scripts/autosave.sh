#!/bin/sh
PATH=/bin:/sbin:/usr/bin:/usr/sbin; export PATH

basedir="/Applications/PCKeyboardHack"

[ "`sysctl -n pckeyboardhack.changed`" != "1" ] && exit 0

"$basedir/scripts/save.sh"
sysctl -w pckeyboardhack.changed=0
exit 0
