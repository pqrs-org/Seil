SYSCTL_FILE = ../../../../../files/prefpane/sysctl.xml

all:
	cat $(SYSCTL_FILE) | ruby ./make-code.rb code_initialize > output/include.code_initialize.cpp
	cat $(SYSCTL_FILE) | ruby ./make-code.rb code_terminate > output/include.code_terminate.cpp
	cat $(SYSCTL_FILE) | ruby ./make-code.rb code_setkeycode > output/include.code_setkeycode.cpp

clean:
	rm -f output/*
