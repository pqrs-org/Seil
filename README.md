PCKeyboardHack
==============

PCKeyboardHack applies a patch to a keyboard driver.
You can change CapsLock behavior, and activate dead keys on non-Apple keyboard.


System requirements
-------------------

Mac OS X 10.6 or higher.

If you require PCKeyboardHack for Mac OS X 10.5.x, use PCKeyboardHack 5.1.0.


How to build
------------

Requirements:

* OS X 10.7
* Xcode 4.3+
* Command Line Tools for Xcode
* Auxiliary Tools for Xcode

Please install PackageMaker.app in /Applications/Utilities.
(PackageMaker.app is included in Auxiliary Tools for Xcode.)

### Step1

Getting source code.
Execute a following command in Terminal.app.

<pre>
git clone https://github.com/tekezo/PCKeyboardHack.git
</pre>

### Step2

Building a package.
Execute a following command in Terminal.app.

<pre>
cd PCKeyboardHack
make
</pre>

Then, PCKeyboardHack-VERSION.pkg.zip has been created in the current directory.
It's a distributable package.
