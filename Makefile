all:
	./make-package.sh

build:
	$(MAKE) -C pkginfo
	$(MAKE) -C src

clean:
	$(MAKE) -C pkginfo clean
	$(MAKE) -C src clean

gitclean:
	git clean -f -x -d

ibtool-upgrade:
	for f in `find * -name "*.xib"`; do xcrun ibtool --upgrade $$f; done
