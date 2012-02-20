all:
	./make-package.sh

build:
	$(MAKE) -C pkginfo
	$(MAKE) -C src

clean:
	git clean -f -x -d

source:
	./make-source.sh
