#CONFIGURATION = Debug
CONFIGURATION = Release

all:
	$(MAKE) -C ../common/generate
	./scripts/make-version.sh
	xcodebuild -alltargets -configuration $(CONFIGURATION) MODULE_VERSION=`cat ../../../../version` CURRENT_PROJECT_VERSION=`cat ../../../../version` build

clean:
	$(MAKE) -C ../common/generate clean
	rm -rf build
	rm -f *.xcodeproj/*.mode1
	rm -f *.xcodeproj/*.mode1v3
	rm -f *.xcodeproj/*.pbxuser
	rm -rf *.xcodeproj/xcuserdata
	rm -rf *.xcodeproj/project.xcworkspace/xcuserdata

xcode:
	open *.xcodeproj

reload:
	sudo ./scripts/unload.sh
	sudo ./scripts/load.sh
