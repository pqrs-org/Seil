#CONFIGURATION = Debug
CONFIGURATION = Release

all:
	pod install --no-repo-update
	$(MAKE) -C ../../../pkginfo
	$(MAKE) -C ../../bridge/generator/bridge_version
	$(MAKE) -C ../../bridge/generator/config
	xcodebuild \
		-workspace *.xcworkspace \
		-scheme Pods \
		-configuration $(CONFIGURATION) \
		build \
		SYMROOT=`pwd`/build
	xcodebuild -alltargets -configuration $(CONFIGURATION) build
	install -m 644 ../../share/Resources/app.icns build/Release/Seil.app/Contents/Frameworks/Sparkle.framework/Versions/A/Resources/Autoupdate.app/Contents/Resources/AppIcon.icns

clean:
	rm -rf build
	rm -f *.xcodeproj/*.mode1
	rm -f *.xcodeproj/*.mode1v3
	rm -f *.xcodeproj/*.pbxuser
	rm -rf *.xcodeproj/xcuserdata
	rm -rf *.xcodeproj/project.xcworkspace/xcuserdata

xcode:
	open *.xcworkspace

run:
	./build/Release/Seil.app/Contents/MacOS/Seil

podupdate:
	pod update
