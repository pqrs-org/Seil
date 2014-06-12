#!/bin/sh

PATH=/bin:/sbin:/usr/bin:/usr/sbin; export PATH

# --------------------------------------------------
sudo rm -rf /tmp/Seil
mkdir /tmp/Seil

sudo cp -R build/Release/Seil.kext /tmp/Seil/Seil.signed.kext
bash ../../../../files/extra/codesign.sh /tmp/Seil
sudo chown -R root:wheel /tmp/Seil

sudo kextutil -t /tmp/Seil/Seil.signed.kext
