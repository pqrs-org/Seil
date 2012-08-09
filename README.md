PCKeyboardHack
==============

PCKeyboardHack applies a patch to a keyboard driver.

You can change CapsLock behavior. (For example, changing CapsLock to Delete Key.)
And it can activate International Keys on Non-Apple keyboard.


System requirements
-------------------

Mac OS X 10.7 or higher.

* If you require PCKeyboardHack for OS X 10.5, use PCKeyboardHack 5.1.0.
* If you require PCKeyboardHack for OS X 10.6, use PCKeyboardHack 7.4.0.

How to build
------------

Requirements:

* OS X 10.8
* Xcode 4.4+
* Command Line Tools for Xcode
* Auxiliary Tools for Xcode

Please install PackageMaker.app in /Applications/Utilities.
(PackageMaker.app is included in Auxiliary Tools for Xcode.)

### Step1: Getting source code

Execute a following command in Terminal.app.

<pre>
git clone --depth 10 https://github.com/tekezo/PCKeyboardHack.git
</pre>

### Step2: Building a package

Execute a following command in Terminal.app.

<pre>
cd PCKeyboardHack
make
</pre>

Then, PCKeyboardHack-VERSION.dmg has been created in the current directory.
It's a distributable package.
