#CONFIGURATION = Debug
CONFIGURATION = Release

all:
	pod install --no-repo-update
	$(MAKE) -C ../../../pkginfo
	$(MAKE) -C ../../bridge/generator/bridge_version
	$(MAKE) -C ../../bridge/generator/config
	xcodebuild \
		-workspace *.xcworkspace \
		-scheme Seil_server \
		-configuration $(CONFIGURATION) \
		build \
		SYMROOT=`pwd`/build

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
