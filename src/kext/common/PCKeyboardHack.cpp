// -*- Mode: c++; indent-tabs-mode: nil; -*-

#include "base.hpp"
#include "PCKeyboardHack.hpp"
#include "config.hpp"
#include "keymap.hpp"

org_pqrs_driver_PCKeyboardHack::HookedKeyboard org_pqrs_driver_PCKeyboardHack::hookedKeyboard[MAXNUM_KEYBOARD];

// ----------------------------------------------------------------------
// http://developer.apple.com/documentation/DeviceDrivers/Conceptual/WritingDeviceDriver/CPluPlusRuntime/chapter_2_section_3.html

// This convention makes it easy to invoke base class member functions.
#define super    IOService
// You cannot use the "super" macro here, however, with the
//  OSDefineMetaClassAndStructors macro.
OSDefineMetaClassAndStructors(org_pqrs_driver_PCKeyboardHack, IOService)

// ----------------------------------------------------------------------
void
org_pqrs_driver_PCKeyboardHack::customizeAllKeymap(void) {
  for ( int i = 0; i < MAXNUM_KEYBOARD; i++ ) {
    hookedKeyboard[i].refresh();
  }
}


// ----------------------------------------------------------------------
void
org_pqrs_driver_PCKeyboardHack::HookedKeyboard::initialize(IOHIKeyboard *p)
{
  IOHIDKeyboard *hid = OSDynamicCast(IOHIDKeyboard, p);
  if (hid) {
    kbd = p;
    keycode_f1 = hid->_usb_2_adb_keymap[org_pqrs_PCKeyboardHack::KeyMapIndex::F1];
    keycode_f2 = hid->_usb_2_adb_keymap[org_pqrs_PCKeyboardHack::KeyMapIndex::F2];
    keycode_f3 = hid->_usb_2_adb_keymap[org_pqrs_PCKeyboardHack::KeyMapIndex::F3];
    keycode_f4 = hid->_usb_2_adb_keymap[org_pqrs_PCKeyboardHack::KeyMapIndex::F4];
    keycode_f5 = hid->_usb_2_adb_keymap[org_pqrs_PCKeyboardHack::KeyMapIndex::F5];
    keycode_jis_xfer = hid->_usb_2_adb_keymap[org_pqrs_PCKeyboardHack::KeyMapIndex::JIS_XFER];
    keycode_jis_nfer = hid->_usb_2_adb_keymap[org_pqrs_PCKeyboardHack::KeyMapIndex::JIS_NFER];
    keycode_jis_kana = hid->_usb_2_adb_keymap[org_pqrs_PCKeyboardHack::KeyMapIndex::JIS_KANA];
  }
  refresh();
}

void
org_pqrs_driver_PCKeyboardHack::HookedKeyboard::terminate(void)
{
  if (! kbd) return;

  IOHIDKeyboard *hid = OSDynamicCast(IOHIDKeyboard, kbd);
  if (hid) {
    hid->_usb_2_adb_keymap[org_pqrs_PCKeyboardHack::KeyMapIndex::F1] = keycode_f1;
    hid->_usb_2_adb_keymap[org_pqrs_PCKeyboardHack::KeyMapIndex::F2] = keycode_f2;
    hid->_usb_2_adb_keymap[org_pqrs_PCKeyboardHack::KeyMapIndex::F3] = keycode_f3;
    hid->_usb_2_adb_keymap[org_pqrs_PCKeyboardHack::KeyMapIndex::F4] = keycode_f4;
    hid->_usb_2_adb_keymap[org_pqrs_PCKeyboardHack::KeyMapIndex::F5] = keycode_f5;
    hid->_usb_2_adb_keymap[org_pqrs_PCKeyboardHack::KeyMapIndex::JIS_XFER] = keycode_jis_xfer;
    hid->_usb_2_adb_keymap[org_pqrs_PCKeyboardHack::KeyMapIndex::JIS_NFER] = keycode_jis_nfer;
    hid->_usb_2_adb_keymap[org_pqrs_PCKeyboardHack::KeyMapIndex::JIS_KANA] = keycode_jis_kana;
    kbd = NULL;
  }
}

void
org_pqrs_driver_PCKeyboardHack::HookedKeyboard::refresh(void)
{
  if (! kbd) return;

  IOHIDKeyboard *hid = OSDynamicCast(IOHIDKeyboard, kbd);
  if (hid) {
    if (org_pqrs_PCKeyboardHack::config.enable_f1) {
      hid->_usb_2_adb_keymap[org_pqrs_PCKeyboardHack::KeyMapIndex::F1] = org_pqrs_PCKeyboardHack::config.keycode_f1;
    } else {
      hid->_usb_2_adb_keymap[org_pqrs_PCKeyboardHack::KeyMapIndex::F1] = keycode_f1;
    }
    if (org_pqrs_PCKeyboardHack::config.enable_f2) {
      hid->_usb_2_adb_keymap[org_pqrs_PCKeyboardHack::KeyMapIndex::F2] = org_pqrs_PCKeyboardHack::config.keycode_f2;
    } else {
      hid->_usb_2_adb_keymap[org_pqrs_PCKeyboardHack::KeyMapIndex::F2] = keycode_f2;
    }
    if (org_pqrs_PCKeyboardHack::config.enable_f3) {
      hid->_usb_2_adb_keymap[org_pqrs_PCKeyboardHack::KeyMapIndex::F3] = org_pqrs_PCKeyboardHack::config.keycode_f3;
    } else {
      hid->_usb_2_adb_keymap[org_pqrs_PCKeyboardHack::KeyMapIndex::F3] = keycode_f3;
    }
    if (org_pqrs_PCKeyboardHack::config.enable_f4) {
      hid->_usb_2_adb_keymap[org_pqrs_PCKeyboardHack::KeyMapIndex::F4] = org_pqrs_PCKeyboardHack::config.keycode_f4;
    } else {
      hid->_usb_2_adb_keymap[org_pqrs_PCKeyboardHack::KeyMapIndex::F4] = keycode_f4;
    }
    if (org_pqrs_PCKeyboardHack::config.enable_f5) {
      hid->_usb_2_adb_keymap[org_pqrs_PCKeyboardHack::KeyMapIndex::F5] = org_pqrs_PCKeyboardHack::config.keycode_f5;
    } else {
      hid->_usb_2_adb_keymap[org_pqrs_PCKeyboardHack::KeyMapIndex::F5] = keycode_f5;
    }

    if (org_pqrs_PCKeyboardHack::config.enable_jis_xfer) {
      hid->_usb_2_adb_keymap[org_pqrs_PCKeyboardHack::KeyMapIndex::JIS_XFER] = org_pqrs_PCKeyboardHack::config.keycode_jis_xfer;
    } else {
      hid->_usb_2_adb_keymap[org_pqrs_PCKeyboardHack::KeyMapIndex::JIS_XFER] = keycode_jis_xfer;
    }
    if (org_pqrs_PCKeyboardHack::config.enable_jis_nfer) {
      hid->_usb_2_adb_keymap[org_pqrs_PCKeyboardHack::KeyMapIndex::JIS_NFER] = org_pqrs_PCKeyboardHack::config.keycode_jis_nfer;
    } else {
      hid->_usb_2_adb_keymap[org_pqrs_PCKeyboardHack::KeyMapIndex::JIS_NFER] = keycode_jis_nfer;
    }
    if (org_pqrs_PCKeyboardHack::config.enable_jis_kana) {
      hid->_usb_2_adb_keymap[org_pqrs_PCKeyboardHack::KeyMapIndex::JIS_KANA] = org_pqrs_PCKeyboardHack::config.keycode_jis_kana;
    } else {
      hid->_usb_2_adb_keymap[org_pqrs_PCKeyboardHack::KeyMapIndex::JIS_KANA] = keycode_jis_kana;
    }
  }
}

// ----------------------------------------------------------------------
bool
org_pqrs_driver_PCKeyboardHack::init(OSDictionary *dict)
{
  IOLog("PCKeyboardHack::init\n");

  bool res = super::init(dict);
  org_pqrs_PCKeyboardHack::sysctl_register();

  for (int i = 0; i < MAXNUM_KEYBOARD; ++i) {
    hookedKeyboard[i].kbd = NULL;
  }

  return res;
}

void
org_pqrs_driver_PCKeyboardHack::free(void)
{
  IOLog("PCKeyboardHack::free\n");

  org_pqrs_PCKeyboardHack::sysctl_unregister();
  super::free();
}

IOService *
org_pqrs_driver_PCKeyboardHack::probe(IOService *provider, SInt32 *score)
{
  IOService *res = super::probe(provider, score);
  return res;
}

bool
org_pqrs_driver_PCKeyboardHack::start(IOService *provider)
{
  bool res = super::start(provider);
  IOLog("PCKeyboardHack::start\n");
  if (!res) { return res; }

  keyboardNotifier = addNotification(gIOMatchedNotification,
                                     serviceMatching("IOHIKeyboard"),
                                     ((IOServiceNotificationHandler)&(org_pqrs_driver_PCKeyboardHack::notifier_hookKeyboard)),
                                     this, NULL, 0);
  if (keyboardNotifier == NULL) {
    IOLog("[PCKeyboardHack ERROR] addNotification(gIOMatchedNotification)\n");
    return false;
  }

  terminatedNotifier = addNotification(gIOTerminatedNotification,
                                       serviceMatching("IOHIKeyboard"),
                                       ((IOServiceNotificationHandler)&(org_pqrs_driver_PCKeyboardHack::notifier_unhookKeyboard)),
                                       this, NULL, 0);
  if (terminatedNotifier == NULL) {
    IOLog("[PCKeyboardHack ERROR] addNotification(gIOTerminatedNotification)\n");
    return false;
  }

  return res;
}

void
org_pqrs_driver_PCKeyboardHack::stop(IOService *provider)
{
  for (int i = 0; i < MAXNUM_KEYBOARD; ++i) {
    if (hookedKeyboard[i].kbd != NULL) {
      restoreKeyMap(hookedKeyboard[i].kbd);
    }
  }

  if (keyboardNotifier) {
    keyboardNotifier->remove();
  }
  if (terminatedNotifier) {
    terminatedNotifier->remove();
  }

  IOLog("PCKeyboardHack::stop\n");
  super::stop(provider);
}


// ----------------------------------------------------------------------
org_pqrs_driver_PCKeyboardHack::HookedKeyboard *
org_pqrs_driver_PCKeyboardHack::new_hookedKeyboard(void)
{
  for (int i = 0; i < MAXNUM_KEYBOARD; ++i) {
    if (hookedKeyboard[i].kbd == NULL) {
      return hookedKeyboard + i;
    }
  }
  return NULL;
}

org_pqrs_driver_PCKeyboardHack::HookedKeyboard *
org_pqrs_driver_PCKeyboardHack::search_hookedKeyboard(const IOHIKeyboard *kbd)
{
  if (kbd == NULL) {
    return NULL;
  }
  for (int i = 0; i < MAXNUM_KEYBOARD; ++i) {
    if (hookedKeyboard[i].kbd == kbd) {
      return hookedKeyboard + i;
    }
  }
  return NULL;
}

// ----------------------------------------------------------------------
bool
org_pqrs_driver_PCKeyboardHack::notifier_hookKeyboard(org_pqrs_driver_PCKeyboardHack *self, void *ref, IOService *newService)
{
  IOLog("PCKeyboardHack::notifier_hookKeyboard\n");

  IOHIKeyboard *kbd = OSDynamicCast(IOHIKeyboard, newService);
  return customizeKeyMap(kbd);
}

bool
org_pqrs_driver_PCKeyboardHack::notifier_unhookKeyboard(org_pqrs_driver_PCKeyboardHack *self, void *ref, IOService *newService)
{
  IOLog("PCKeyboardHack::notifier_unhookKeyboard\n");

  IOHIKeyboard *kbd = OSDynamicCast(IOHIKeyboard, newService);
  return restoreKeyMap(kbd);
}

bool
org_pqrs_driver_PCKeyboardHack::customizeKeyMap(IOHIKeyboard *kbd)
{
  if (! kbd) return false;

  const char *name = kbd->getName();
  IOLog("PCKeyboardHack::customizeKeymap name = %s\n", name);

  // AppleADBKeyboard == PowerBook, IOHIKeyboard == MacBook, MacBook Pro, Mac mini, ...
  if (strcmp(name, "IOHIDKeyboard") != 0 && strcmp(name, "AppleADBKeyboard") != 0) return false;

  HookedKeyboard *p = new_hookedKeyboard();
  if (! p) return false;

  p->initialize(kbd);
  return true;
}

bool
org_pqrs_driver_PCKeyboardHack::restoreKeyMap(IOHIKeyboard *kbd)
{
  if (! kbd) return false;

  HookedKeyboard *p = search_hookedKeyboard(kbd);
  if (! p) return false;

  IOLog("PCKeyboardHack::restoreKeyMap 0x%x\n", kbd);
  p->terminate();
  return true;
}
