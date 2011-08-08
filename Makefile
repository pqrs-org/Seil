all:
	./make-package.sh

build:
	$(MAKE) -C pkginfo
	$(MAKE) -C src

clean:
	$(MAKE) -C src clean
	rm -rf pkgroot
	rm -rf *.pkg
	rm -rf *.zip

source:
	./make-source.sh
