XMLFILE = ../../../files/prefpane/checkbox.xml

all:
	mkdir -p output
	/usr/bin/tidy -q -errors -xml -raw $(XMLFILE)
	ruby ./make-code.rb $(XMLFILE)

clean:
	rm -f output/*
