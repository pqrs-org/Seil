SYSCTL_FILE = ../../../../files/prefpane/sysctl.xml

all:
	mkdir -p output
	cat $(SYSCTL_FILE) | ruby ./make-code.rb hpp > output/include.config.hpp
	cat $(SYSCTL_FILE) | ruby ./make-code.rb default > output/include.config.default.hpp
	cat $(SYSCTL_FILE) | ruby ./make-code.rb cpp_SYSCTL > output/include.config_SYSCTL.cpp
	cat $(SYSCTL_FILE) | ruby ./make-code.rb cpp_register > output/include.config_register.cpp
	cat $(SYSCTL_FILE) | ruby ./make-code.rb cpp_unregister > output/include.config_unregister.cpp
	cat $(SYSCTL_FILE) | ruby ./make-code.rb code_initialize > output/include.code_initialize.cpp
	cat $(SYSCTL_FILE) | ruby ./make-code.rb code_terminate > output/include.code_terminate.cpp
	cat $(SYSCTL_FILE) | ruby ./make-code.rb code_setkeycode > output/include.code_setkeycode.cpp
	cat $(SYSCTL_FILE) | ruby ./make-code.rb code_hpp > output/include.code.hpp

clean:
	rm -f output/*
