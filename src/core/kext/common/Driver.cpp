// -*- Mode: c++; indent-tabs-mode: nil; -*-

// The original code was written by YASUDA Yoshinori.

#define protected public // A hack for access private member of IOHIKeyboard
#include <IOKit/hidsystem/IOHIKeyboard.h>
// included from Leopard or Tiger folder according to $USER_HEADER_SEARCH_PATHS in Build tab of Project setting
#include "IOHIDKeyboard.h"
#undef protected
#include <IOKit/IOLib.h>

#include "Driver.hpp"
#include "GlobalLock.hpp"
#include "IOLogWrapper.hpp"
#include "ostype.hpp"

org_pqrs_driver_Seil::HookedKeyboard org_pqrs_driver_Seil::hookedKeyboard_[MAXNUM_KEYBOARD];
BridgeConfig org_pqrs_driver_Seil::configuration_;

// ----------------------------------------------------------------------
// http://developer.apple.com/documentation/DeviceDrivers/Conceptual/WritingDeviceDriver/CPluPlusRuntime/chapter_2_section_3.html

// This convention makes it easy to invoke base class member functions.
#define super IOService
// You cannot use the "super" macro here, however, with the
//  OSDefineMetaClassAndStructors macro.
OSDefineMetaClassAndStructors(org_pqrs_driver_Seil, IOService);

// ----------------------------------------------------------------------
void org_pqrs_driver_Seil::HookedKeyboard::initialize(IOHIKeyboard* p) {
  IOHIDKeyboard* hid = OSDynamicCast(IOHIDKeyboard, p);

  if (hid) {
    kbd_ = p;

    for (int i = 0; i < BRIDGE_KEY_INDEX__END__; ++i) {
      KeyMapIndex::Value idx = KeyMapIndex::bridgeKeyindexToValue(i);
      if (idx != KeyMapIndex::NONE) {
        originalKeyCode_[i] = hid->_usb_2_adb_keymap[idx];
      }
    }

#if 0
    // Dump _usb_2_adb_keymap
    for (size_t i = 0; i < sizeof(hid->_usb_2_adb_keymap) / sizeof(hid->_usb_2_adb_keymap[0]); ++i) {
      IOLOG_INFO("%d = %d\n", static_cast<int>(i), hid->_usb_2_adb_keymap[i]);
    }
#endif
  }

  refresh();
}

void org_pqrs_driver_Seil::HookedKeyboard::terminate(void) {
  restore();
  kbd_ = NULL;
}

void org_pqrs_driver_Seil::HookedKeyboard::restore(void) {
  if (!kbd_) return;

  IOHIDKeyboard* hid = OSDynamicCast(IOHIDKeyboard, kbd_);
  if (hid) {
    for (int i = 0; i < BRIDGE_KEY_INDEX__END__; ++i) {
      KeyMapIndex::Value idx = KeyMapIndex::bridgeKeyindexToValue(i);
      if (idx != KeyMapIndex::NONE) {
        hid->_usb_2_adb_keymap[idx] = originalKeyCode_[i];
      }
    }
  }
}

void org_pqrs_driver_Seil::HookedKeyboard::refresh(void) {
  if (!kbd_) return;

  // Some settings change the same _usb_2_adb_keymap.
  //   For example:
  //     Both "International 4 Key" and "For Japanese > XFER Key on PC keyboard" change
  //     kHIDUsage_KeyboardInternational4.
  //
  // Therefore, we restore original key code at first.
  // Then we change key code for enabled keys.
  restore();

  IOHIDKeyboard* hid = OSDynamicCast(IOHIDKeyboard, kbd_);
  if (hid) {
    for (int i = 0; i < BRIDGE_KEY_INDEX__END__; ++i) {
      KeyMapIndex::Value idx = KeyMapIndex::bridgeKeyindexToValue(i);
      if (idx != KeyMapIndex::NONE) {
        if (configuration_.config[i].enabled) {
          hid->_usb_2_adb_keymap[idx] = configuration_.config[i].keycode;
        }
      }
    }
  }
}

// ----------------------------------------------------------------------
bool org_pqrs_driver_Seil::init(OSDictionary* dict) {
  IOLOG_INFO("init %s\n", ostype);

  bool res = super::init(dict);

  memset(&configuration_, 0, sizeof(configuration_));

  return res;
}

void org_pqrs_driver_Seil::free(void) {
  IOLOG_INFO("free\n");

  super::free();
}

IOService*
org_pqrs_driver_Seil::probe(IOService* provider, SInt32* score) {
  IOService* res = super::probe(provider, score);
  return res;
}

bool org_pqrs_driver_Seil::start(IOService* provider) {
  IOLOG_INFO("start\n");

  bool res = super::start(provider);
  if (!res) { return res; }

  org_pqrs_Seil::GlobalLock::initialize();

  notifier_hookKeyboard_ = addMatchingNotification(gIOMatchedNotification,
                                                   serviceMatching("IOHIKeyboard"),
                                                   org_pqrs_driver_Seil::IOHIKeyboard_gIOMatchedNotification_callback,
                                                   this, NULL, 0);
  if (notifier_hookKeyboard_ == NULL) {
    IOLOG_ERROR("initialize_notification notifier_hookKeyboard_ == NULL\n");
    return false;
  }

  notifier_unhookKeyboard_ = addMatchingNotification(gIOTerminatedNotification,
                                                     serviceMatching("IOHIKeyboard"),
                                                     org_pqrs_driver_Seil::IOHIKeyboard_gIOTerminatedNotification_callback,
                                                     this, NULL, 0);
  if (notifier_unhookKeyboard_ == NULL) {
    IOLOG_ERROR("initialize_notification notifier_unhookKeyboard_ == NULL\n");
    return false;
  }

  // Publish ourselves so clients can find us
  registerService();

  return res;
}

void org_pqrs_driver_Seil::stop(IOService* provider) {
  IOLOG_INFO("stop\n");

  for (int i = 0; i < MAXNUM_KEYBOARD; ++i) {
    hookedKeyboard_[i].terminate();
  }

  if (notifier_hookKeyboard_) notifier_hookKeyboard_->remove();
  if (notifier_unhookKeyboard_) notifier_unhookKeyboard_->remove();

  org_pqrs_Seil::GlobalLock::terminate();

  super::stop(provider);
}

// ----------------------------------------------------------------------
org_pqrs_driver_Seil::HookedKeyboard*
org_pqrs_driver_Seil::new_hookedKeyboard(void) {
  for (int i = 0; i < MAXNUM_KEYBOARD; ++i) {
    if (hookedKeyboard_[i].get() == NULL) {
      return hookedKeyboard_ + i;
    }
  }
  return NULL;
}

org_pqrs_driver_Seil::HookedKeyboard*
org_pqrs_driver_Seil::search_hookedKeyboard(const IOHIKeyboard* kbd) {
  if (kbd == NULL) {
    return NULL;
  }
  for (int i = 0; i < MAXNUM_KEYBOARD; ++i) {
    if (hookedKeyboard_[i].get() == kbd) {
      return hookedKeyboard_ + i;
    }
  }
  return NULL;
}

// ----------------------------------------------------------------------
bool org_pqrs_driver_Seil::isTargetDevice(IOHIKeyboard* kbd) {
  if (!kbd) return false;

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
      vendorID = vid->unsigned32BitValue();
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

bool org_pqrs_driver_Seil::IOHIKeyboard_gIOMatchedNotification_callback(void* target, void* refCon, IOService* newService, IONotifier* notifier) {
  // IOLOG_INFO("notifier_hookKeyboard\n");

  IOHIKeyboard* kbd = OSDynamicCast(IOHIKeyboard, newService);
  if (!isTargetDevice(kbd)) return true;
  return customizeKeyMap(kbd);
}

bool org_pqrs_driver_Seil::IOHIKeyboard_gIOTerminatedNotification_callback(void* target, void* refCon, IOService* newService, IONotifier* notifier) {
  // IOLOG_INFO("notifier_unhookKeyboard\n");

  IOHIKeyboard* kbd = OSDynamicCast(IOHIKeyboard, newService);
  if (!isTargetDevice(kbd)) return true;
  return restoreKeyMap(kbd);
}

bool org_pqrs_driver_Seil::customizeKeyMap(IOHIKeyboard* kbd) {
  if (!kbd) return false;

  const char* name = kbd->getName();
  // IOLOG_INFO("customizeKeymap name = %s\n", name);

  // AppleADBKeyboard == PowerBook, IOHIKeyboard == MacBook, MacBook Pro, Mac mini, ...
  if (strcmp(name, "IOHIDKeyboard") != 0 && strcmp(name, "AppleADBKeyboard") != 0) return false;

  HookedKeyboard* p = new_hookedKeyboard();
  if (!p) return false;

  p->initialize(kbd);
  return true;
}

bool org_pqrs_driver_Seil::restoreKeyMap(IOHIKeyboard* kbd) {
  if (!kbd) return false;

  HookedKeyboard* p = search_hookedKeyboard(kbd);
  if (!p) return false;

  // IOLOG_INFO("restoreKeyMap %p\n", kbd);
  p->terminate();
  return true;
}

// ----------------------------------------------------------------------
void org_pqrs_driver_Seil::setConfiguration(const BridgeConfig& newval) {
  configuration_ = newval;

  // ----------------------------------------
  // refresh all devices.
  for (int i = 0; i < MAXNUM_KEYBOARD; i++) {
    hookedKeyboard_[i].refresh();
  }
}

void org_pqrs_driver_Seil::unsetConfiguration(void) {
  BridgeConfig newval;
  memset(&newval, 0, sizeof(newval));
  setConfiguration(newval);
}
