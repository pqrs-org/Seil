#!/bin/sh

PATH=/bin:/sbin:/usr/bin:/usr/sbin; export PATH

# --------------------------------------------------
sudo rm -rf /tmp/PCKeyboardHack
mkdir /tmp/PCKeyboardHack

sudo cp -R build/Release/PCKeyboardHack.kext /tmp/PCKeyboardHack/PCKeyboardHack.signed.kext
bash ../../../../files/extra/codesign.sh /tmp/PCKeyboardHack
sudo chown -R root:wheel /tmp/PCKeyboardHack

sudo kextutil -t /tmp/PCKeyboardHack/PCKeyboardHack.signed.kext
