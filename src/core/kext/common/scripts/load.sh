#!/bin/sh

sudo cp -R build/Release/PCKeyboardHack.kext /tmp/
sudo kextutil -t /tmp/PCKeyboardHack.kext
