all:
	$(MAKE) -C ../../../pkginfo
	$(MAKE) -C ../../bridge/generator/bridge_version
	$(MAKE) -C ../../bridge/generator/config
	$(MAKE) -C 10.9
	$(MAKE) -C 10.10
	$(MAKE) -C 10.11

clean:
	$(MAKE) -C 10.9 clean
	$(MAKE) -C 10.10 clean
	$(MAKE) -C 10.11 clean
