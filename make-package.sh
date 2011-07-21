#!/bin/sh

version=$(cat version)

packagemaker=/Developer/Applications/Utilities/PackageMaker.app/Contents/MacOS/PackageMaker
pkgName="PCKeyboardHack-${version}.pkg"

make clean build || exit $?

# --------------------------------------------------
# http://developer.apple.com/documentation/Darwin/Conceptual/KEXTConcept/KEXTConceptPackaging/packaging_kext.html
echo "Copy Files"

sudo rm -rf pkgroot
sudo mkdir -p pkgroot

basedir="/Library/org.pqrs/PCKeyboardHack"
sudo mkdir -p "pkgroot/$basedir"
for ostype in 10.6 10.7; do
    sudo cp -R src/core/kext/${ostype}/build/Release/PCKeyboardHack.kext "pkgroot/$basedir/PCKeyboardHack.${ostype}.kext"
done
sudo cp -R files/prefpane "pkgroot/$basedir"
sudo cp -R files/scripts "pkgroot/$basedir"

sudo mkdir -p "pkgroot/$basedir/extra"
sudo cp -R pkginfo/Resources/preflight "pkgroot/$basedir/extra/uninstall.sh"
sudo cp -R files/extra/launchUninstaller.sh "pkgroot/$basedir/extra/"

sudo mkdir -p "pkgroot/Library"
sudo cp -R files/LaunchAgents pkgroot/Library
sudo cp -R files/LaunchDaemons pkgroot/Library

sudo mkdir -p "pkgroot/$basedir/app"
sudo cp -R "src/core/server/build/Release/PCKeyboardHack_server.app" "pkgroot/$basedir/app"
sudo cp -R "src/util/uninstaller/build/Release/uninstaller.app" "pkgroot/$basedir/app"

sudo mkdir -p "pkgroot/Library/PreferencePanes"
sudo cp -R "src/util/prefpane/build/Release/PCKeyboardHack.prefPane" "pkgroot/Library/PreferencePanes"

sudo find pkgroot -type d -print0 | xargs -0 sudo chmod 755
sudo find pkgroot -type f -print0 | xargs -0 sudo chmod 644
sudo find pkgroot -name '*.sh' -print0 | xargs -0 sudo chmod 755
sudo chmod 755 pkgroot/$basedir/app/PCKeyboardHack_server.app/Contents/MacOS/PCKeyboardHack_server
sudo chmod 755 pkgroot/$basedir/app/uninstaller.app/Contents/MacOS/uninstaller
sudo chown -R root:wheel pkgroot

sudo chmod 1775 pkgroot/Library
sudo chown root:admin pkgroot/Library

# --------------------------------------------------
echo "Exec PackageMaker"

sudo rm -rf $pkgName
sudo $packagemaker \
    --root pkgroot \
    --info pkginfo/Info.plist \
    --resources pkginfo/Resources \
    --title "PCKeyboardHack $version" \
    --no-recommend \
    --no-relocate \
    --out $pkgName

# --------------------------------------------------
echo "Make Archive"

sudo chown -R root:wheel $pkgName
sudo zip -r $pkgName.zip $pkgName
sudo rm -rf $pkgName
sudo chmod 644 $pkgName.zip
unzip $pkgName.zip

# --------------------------------------------------
echo "Cleanup"
sudo rm -rf pkgroot
make -C src clean
