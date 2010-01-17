all:
	./make-package.sh

build:
	$(MAKE) -C pkginfo
	$(MAKE) -C src
	mkdir -p files/share
	./util/make-reset.rb files/prefpane/sysctl.xml > files/share/reset

clean:
	$(MAKE) -C src clean
	sudo rm -rf pkgroot
	sudo rm -rf *.pkg
	sudo rm -rf *.zip

source:
	./make-source.sh
