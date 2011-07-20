// -*- Mode: c++; indent-tabs-mode: nil; -*-

// The original code was written by YASUDA Yoshinori.

#include "base.hpp"
#include "Driver.hpp"

org_pqrs_driver_PCKeyboardHack::HookedKeyboard org_pqrs_driver_PCKeyboardHack::hookedKeyboard_[MAXNUM_KEYBOARD];
BridgeUserClientStruct org_pqrs_driver_PCKeyboardHack::configuration_;

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
  for (int i = 0; i < MAXNUM_KEYBOARD; i++) {
    hookedKeyboard_[i].refresh();
  }
}


// ----------------------------------------------------------------------
void
org_pqrs_driver_PCKeyboardHack::HookedKeyboard::initialize(IOHIKeyboard* p)
{
  IOHIDKeyboard* hid = OSDynamicCast(IOHIDKeyboard, p);

  if (hid) {
    kbd = p;

    for (int i = 0; i < BRIDGE_KEY_INDEX__END__; ++i) {
      KeyMapIndex::Value idx = KeyMapIndex::bridgeKeyindexToValue(i);
      if (idx != KeyMapIndex::NONE) {
        originalKeyCode[i] = hid->_usb_2_adb_keymap[idx];
      }
    }
  }

  refresh();
}

void
org_pqrs_driver_PCKeyboardHack::HookedKeyboard::terminate(void)
{
  if (! kbd) return;

  IOHIDKeyboard* hid = OSDynamicCast(IOHIDKeyboard, kbd);
  if (hid) {
    for (int i = 0; i < BRIDGE_KEY_INDEX__END__; ++i) {
      KeyMapIndex::Value idx = KeyMapIndex::bridgeKeyindexToValue(i);
      if (idx != KeyMapIndex::NONE) {
        hid->_usb_2_adb_keymap[idx] = originalKeyCode[i];
      }
    }

    kbd = NULL;
  }
}

void
org_pqrs_driver_PCKeyboardHack::HookedKeyboard::refresh(void)
{
  if (! kbd) return;

  IOHIDKeyboard* hid = OSDynamicCast(IOHIDKeyboard, kbd);
  if (hid) {
    for (int i = 0; i < BRIDGE_KEY_INDEX__END__; ++i) {
      KeyMapIndex::Value idx = KeyMapIndex::bridgeKeyindexToValue(i);
      if (idx != KeyMapIndex::NONE) {
        if (configuration_.enabled[i]) {
          hid->_usb_2_adb_keymap[idx] = configuration_.keycode[i];
        } else {
          hid->_usb_2_adb_keymap[idx] = originalKeyCode[i];
        }
      }
    }
  }
}

// ----------------------------------------------------------------------
bool
org_pqrs_driver_PCKeyboardHack::init(OSDictionary* dict)
{
  IOLOG_INFO("init\n");

  bool res = super::init(dict);

  for (int i = 0; i < MAXNUM_KEYBOARD; ++i) {
    hookedKeyboard_[i].kbd = NULL;
  }

  memset(&configuration_, 0, sizeof(configuration_));

  return res;
}

void
org_pqrs_driver_PCKeyboardHack::free(void)
{
  IOLOG_INFO("free\n");

  super::free();
}

IOService*
org_pqrs_driver_PCKeyboardHack::probe(IOService* provider, SInt32* score)
{
  IOService* res = super::probe(provider, score);
  return res;
}

bool
org_pqrs_driver_PCKeyboardHack::start(IOService* provider)
{
  IOLOG_INFO("start\n");

  bool res = super::start(provider);
  if (! res) { return res; }

  notifier_hookKeyboard_ = addMatchingNotification(gIOMatchedNotification,
                                                   serviceMatching("IOHIKeyboard"),
                                                   org_pqrs_driver_PCKeyboardHack::IOHIKeyboard_gIOMatchedNotification_callback,
                                                   this, NULL, 0);
  if (notifier_hookKeyboard_ == NULL) {
    IOLOG_ERROR("initialize_notification notifier_hookKeyboard_ == NULL\n");
    return false;
  }

  notifier_unhookKeyboard_ = addMatchingNotification(gIOTerminatedNotification,
                                                     serviceMatching("IOHIKeyboard"),
                                                     org_pqrs_driver_PCKeyboardHack::IOHIKeyboard_gIOTerminatedNotification_callback,
                                                     this, NULL, 0);
  if (notifier_unhookKeyboard_ == NULL) {
    IOLOG_ERROR("initialize_notification notifier_unhookKeyboard_ == NULL\n");
    return false;
  }

  return res;
}

void
org_pqrs_driver_PCKeyboardHack::stop(IOService* provider)
{
  IOLOG_INFO("stop\n");

  for (int i = 0; i < MAXNUM_KEYBOARD; ++i) {
    if (hookedKeyboard_[i].kbd != NULL) {
      restoreKeyMap(hookedKeyboard_[i].kbd);
    }
  }

  if (notifier_hookKeyboard_) notifier_hookKeyboard_->remove();
  if (notifier_unhookKeyboard_) notifier_unhookKeyboard_->remove();

  super::stop(provider);
}


// ----------------------------------------------------------------------
org_pqrs_driver_PCKeyboardHack::HookedKeyboard*
org_pqrs_driver_PCKeyboardHack::new_hookedKeyboard(void)
{
  for (int i = 0; i < MAXNUM_KEYBOARD; ++i) {
    if (hookedKeyboard_[i].kbd == NULL) {
      return hookedKeyboard_ + i;
    }
  }
  return NULL;
}

org_pqrs_driver_PCKeyboardHack::HookedKeyboard*
org_pqrs_driver_PCKeyboardHack::search_hookedKeyboard(const IOHIKeyboard* kbd)
{
  if (kbd == NULL) {
    return NULL;
  }
  for (int i = 0; i < MAXNUM_KEYBOARD; ++i) {
    if (hookedKeyboard_[i].kbd == kbd) {
      return hookedKeyboard_ + i;
    }
  }
  return NULL;
}

// ----------------------------------------------------------------------
bool
org_pqrs_driver_PCKeyboardHack::isTargetDevice(IOHIKeyboard* kbd)
{
  if (! kbd) return false;

  // ------------------------------------------------------------
  uint32_t vendorID = 0;
  uint32_t productID = 0;

  IORegistryEntry* dev = kbd;

  while (dev) {
    const OSNumber* vid = NULL;
    vid = OSDynamicCast(OSNumber, dev->getProperty(kIOHIDVendorIDKey));

    const OSNumber* pid = NULL;
    pid = OSDynamicCast(OSNumber, dev->getProperty(kIOHIDProductIDKey));

    if (vid && pid) {
      vendorID  = vid->unsigned32BitValue();
      productID = pid->unsigned32BitValue();

      goto finish;
    }

    // check parent property.
    dev = dev->getParentEntry(IORegistryEntry::getPlane(kIOServicePlane));
  }

finish:
  enum {
    VENDOR_LOGITECH = 0x046d,
    PRODUCT_LOGITECH_G700_LASER_MOUSE = 0xc06b,
  };

  if (vendorID == VENDOR_LOGITECH && productID == PRODUCT_LOGITECH_G700_LASER_MOUSE) {
    IOLOG_INFO("vendorID:0x%04x, productID:0x%04x (skipped)\n", vendorID, productID);
    return false;
  }

  return true;
}

bool
org_pqrs_driver_PCKeyboardHack::IOHIKeyboard_gIOMatchedNotification_callback(void* target, void* refCon, IOService* newService, IONotifier* notifier)
{
  // IOLOG_INFO("notifier_hookKeyboard\n");

  IOHIKeyboard* kbd = OSDynamicCast(IOHIKeyboard, newService);
  if (! isTargetDevice(kbd)) return true;
  return customizeKeyMap(kbd);
}

bool
org_pqrs_driver_PCKeyboardHack::IOHIKeyboard_gIOTerminatedNotification_callback(void* target, void* refCon, IOService* newService, IONotifier* notifier)
{
  // IOLOG_INFO("notifier_unhookKeyboard\n");

  IOHIKeyboard* kbd = OSDynamicCast(IOHIKeyboard, newService);
  if (! isTargetDevice(kbd)) return true;
  return restoreKeyMap(kbd);
}

bool
org_pqrs_driver_PCKeyboardHack::customizeKeyMap(IOHIKeyboard* kbd)
{
  if (! kbd) return false;

  const char* name = kbd->getName();
  // IOLOG_INFO("customizeKeymap name = %s\n", name);

  // AppleADBKeyboard == PowerBook, IOHIKeyboard == MacBook, MacBook Pro, Mac mini, ...
  if (strcmp(name, "IOHIDKeyboard") != 0 && strcmp(name, "AppleADBKeyboard") != 0) return false;

  HookedKeyboard* p = new_hookedKeyboard();
  if (! p) return false;

  p->initialize(kbd);
  return true;
}

bool
org_pqrs_driver_PCKeyboardHack::restoreKeyMap(IOHIKeyboard* kbd)
{
  if (! kbd) return false;

  HookedKeyboard* p = search_hookedKeyboard(kbd);
  if (! p) return false;

  // IOLOG_INFO("restoreKeyMap %p\n", kbd);
  p->terminate();
  return true;
}
