#!/bin/sh

sudo cp -R build/Release/PCKeyboardHack.kext /tmp/
sudo kextload -t /tmp/PCKeyboardHack.kext
