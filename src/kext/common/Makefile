#CONFIGURATION = Debug
CONFIGURATION = Release

all:
	$(MAKE) -C ../common/generate
	xcodebuild -alltargets -configuration $(CONFIGURATION) build

clean:
	$(MAKE) -C ../common/generate clean
	xcodebuild -alltargets -configuration $(CONFIGURATION) clean
	rm -rf build

reload:
	sudo ./scripts/unload.sh
	sudo ./scripts/load.sh
