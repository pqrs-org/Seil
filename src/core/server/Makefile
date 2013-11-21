#CONFIGURATION = Debug
CONFIGURATION = Release

all:
	$(MAKE) -C ../../../pkginfo
	$(MAKE) -C ../../bridge/generator/bridge_version
	$(MAKE) -C ../../bridge/generator/config
	xcodebuild -alltargets -configuration $(CONFIGURATION) build

clean:
	rm -rf build
	rm -f *.xcodeproj/*.mode1
	rm -f *.xcodeproj/*.mode1v3
	rm -f *.xcodeproj/*.pbxuser
	rm -rf *.xcodeproj/xcuserdata
	rm -rf *.xcodeproj/project.xcworkspace/xcuserdata

xcode:
	open *.xcodeproj

run:
	-launchctl unload /Library/LaunchAgents/org.pqrs.PCKeyboardHack.server.plist 2>/dev/null
	./build/Release/PCKeyboardHack.app/Contents/MacOS/PCKeyboardHack
