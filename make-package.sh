#!/bin/sh

version=$(cat version)

packagemaker=/Developer/Applications/Utilities/PackageMaker.app/Contents/MacOS/PackageMaker
pkgName="PCKeyboardHack-${version}.pkg"

echo "char * const config_version = \"$version-Tiger\";" > src/core/kext/Tiger/version.hpp
echo "char * const config_version = \"$version-Leopard\";" > src/core/kext/Leopard/version.hpp

make clean build || exit $?

# --------------------------------------------------
# http://developer.apple.com/documentation/Darwin/Conceptual/KEXTConcept/KEXTConceptPackaging/packaging_kext.html
echo "Copy Files"

sudo rm -rf pkgroot
sudo mkdir -p pkgroot

basedir="/Library/org.pqrs/PCKeyboardHack"
sudo mkdir -p "pkgroot/$basedir"
for ostype in Tiger Leopard; do
    sudo cp -R src/core/kext/${ostype}/build/Release/PCKeyboardHack.kext "pkgroot/$basedir/PCKeyboardHack.${ostype}.kext"
done
sudo cp -R files/prefpane "pkgroot/$basedir"
sudo cp -R files/scripts "pkgroot/$basedir"
sudo cp -R files/share "pkgroot/$basedir"

sudo mkdir -p "pkgroot/$basedir/extra"
sudo cp -R pkginfo/Resources/preflight "pkgroot/$basedir/extra/uninstall.sh"

sudo mkdir -p "pkgroot/Library"
sudo cp -R files/LaunchDaemons pkgroot/Library

sudo mkdir -p "pkgroot/$basedir/bin"
sudo cp src/bin/set_loginwindow/build/Release/set_loginwindow "pkgroot/$basedir/bin"
sudo cp src/bin/sysctl_confd/build/Release/PCKeyboardHack_sysctl_confd "pkgroot/$basedir/bin"
sudo cp src/bin/sysctl_ctl/build/Release/PCKeyboardHack_sysctl_ctl "pkgroot/$basedir/bin"
sudo cp src/bin/sysctl_reset/build/Release/PCKeyboardHack_sysctl_reset "pkgroot/$basedir/bin"
sudo cp src/bin/sysctl_set/build/Release/PCKeyboardHack_sysctl_set "pkgroot/$basedir/bin"

sudo mkdir -p "pkgroot/Library/PreferencePanes"
sudo cp -R "src/util/prefpane/build/Release/PCKeyboardHack.prefPane" "pkgroot/Library/PreferencePanes"

sudo find pkgroot -type d -print0 | xargs -0 sudo chmod 755
sudo find pkgroot -type f -print0 | xargs -0 sudo chmod 644
sudo find pkgroot -name '*.sh' -print0 | xargs -0 sudo chmod 755
sudo chmod 4755 pkgroot/$basedir/bin/PCKeyboardHack_sysctl_reset
sudo chmod 4755 pkgroot/$basedir/bin/PCKeyboardHack_sysctl_set
sudo chmod 755 pkgroot/$basedir/bin/set_loginwindow
sudo chmod 755 pkgroot/$basedir/bin/PCKeyboardHack_sysctl_confd
sudo chmod 755 pkgroot/$basedir/bin/PCKeyboardHack_sysctl_ctl
sudo chown -R root:wheel pkgroot

sudo chmod 1775 pkgroot/Library
sudo chown root:admin pkgroot/Library

# --------------------------------------------------
echo "Exec PackageMaker"

sudo rm -rf $pkgName
sudo $packagemaker -build \
    -p $pkgName \
    -f pkgroot \
    -ds \
    -r pkginfo/Resources \
    -i pkginfo/Info.plist \
    -d pkginfo/Description.plist

# --------------------------------------------------
echo "Make Archive"

sudo chown -R root:wheel $pkgName
sudo tar zcf $pkgName.tar.gz $pkgName
