#CONFIGURATION = Debug
CONFIGURATION = Release

all:
	xcodebuild -alltargets -configuration $(CONFIGURATION) build

clean:
	rm -rf build
	rm -f *.xcodeproj/*.mode1
	rm -f *.xcodeproj/*.mode1v3
	rm -f *.xcodeproj/*.pbxuser

install:
	rsync -a --delete build/Release/PCKeyboardHack.prefPane $(HOME)/Library/PreferencePanes

uninstall:
	rm -rf $(HOME)/Library/PreferencePanes/PCKeyboardHack.prefPane
