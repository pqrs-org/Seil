Seil
====

Seil applies a patch to a keyboard driver.

You can change CapsLock behavior. (For example, changing CapsLock to Delete Key.)
And it can activate International Keys on Non-Apple keyboard.

Prior to version 10.7.0, Seil was called *PCKeyboardHack*.

Useful links
------------

* Latest build: https://pqrs.org/osx/karabiner/seil.html
* Mirror: http://tekezo.github.io/pqrs.org/


System requirements
-------------------

Mac OS X 10.8 or higher.

* If you require Seil for OS X 10.5, please use PCKeyboardHack 5.1.0.
* If you require Seil for OS X 10.6, please use PCKeyboardHack 7.4.0.
* If you require Seil for OS X 10.7, please use PCKeyboardHack 9.0.0.

How to build
------------

Requirements:

* OS X 10.9+
* Xcode 5.0.1+
* Command Line Tools for Xcode
* Boost 1.54.0+ (header-only) http://www.boost.org/

Please install Boost into /usr/local/include/boost.

### Step 1: Getting source code

Download the source to master.tar.gz in the current directory, this can be re-executed to restart a cancelled download.

    curl -OLC - https://github.com/tekezo/seil/archive/master.tar.gz

Extract the master.tar.gz file to "Seil-master" and delete the tar.gz file

    tar -xvzf master.tar.gz && rm master.tar.gz

### Step 2: Building a package

    cd Seil-master
    make

The `make` script will create a redistributable **Seil-VERSION.dmg** in the current directory.


**Note:**
The build may fail if you have changed any environment variables or if you have modified scripts in the `/usr/bin` locations. Use a clean environment (new account) if this is the case.


Customized Sparkle
------------------

We're using Sparkle to provide a software update feature.<br />
The Sparkle framework is located in "src/core/server/Frameworks/Sparkle.framework".

This built-in binary is built with some patches.

* Set MACOSX_DEPLOYMENT_TARGET 10.6: https://github.com/tekezo/Files/blob/master/patches/Sparkle/MACOSX_DEPLOYMENT_TARGET-10.6.diff
* Adding ".Sparkle" to appSupportPath: https://github.com/andymatuschak/Sparkle/pull/290
