#!/bin/sh

basedir=`dirname $0`

for f in `find $basedir/../../* -name 'project.pbxproj'`; do
    echo "Check $f"

    if [ "$(basename $(dirname $(dirname $f)))/$(basename $(dirname $f))" = "prefpane/PCKeyboardHack.xcodeproj" ]; then
        # prefpane needs GC.
        "$basedir/xcodeproj.rb" GCC_ENABLE_OBJC_GC < $f || exit 1
    elif [ "$(basename $(dirname $(dirname $(dirname $f))))/$(basename $(dirname $(dirname $f)))" = "kext/10.7" ]; then
        "$basedir/xcodeproj.rb" SDKROOT < $f || exit 1
    else
        "$basedir/xcodeproj.rb" < $f || exit 1
    fi
done
