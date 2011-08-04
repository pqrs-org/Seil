// -*- indent-tabs-mode: nil; -*-

#ifndef DRIVER_HPP
#define DRIVER_HPP

#include "base.hpp"
#include "bridge.h"

// http://developer.apple.com/documentation/Darwin/Conceptual/KEXTConcept/KEXTConceptIOKit/hello_iokit.html#//apple_ref/doc/uid/20002366-CIHECHHE
class org_pqrs_driver_PCKeyboardHack : public IOService
{
  OSDeclareDefaultStructors(org_pqrs_driver_PCKeyboardHack);

public:
  virtual bool init(OSDictionary* dictionary = 0);
  virtual void free(void);
  virtual IOService* probe(IOService* provider, SInt32* score);
  virtual bool start(IOService* provider);
  virtual void stop(IOService* provider);

  static void setConfiguration(const BridgeUserClientStruct& newval);
  static void unsetConfiguration(void);

private:
  // see IOHIDUsageTables.h or http://www2d.biglobe.ne.jp/~msyk/keyboard/layout/usbkeycode.html
  class KeyMapIndex {
  public:
    enum Value {
      NONE      = 0, // NONE must be a unique value in this enum.
      CAPSLOCK  = kHIDUsage_KeyboardCapsLock,
      JIS_KANA  = 0x88,
      JIS_NFER  = 0x8b,
      JIS_XFER  = 0x8a,
      COMMAND_L = kHIDUsage_KeyboardLeftGUI,
      COMMAND_R = kHIDUsage_KeyboardRightGUI,
      CONTROL_L = kHIDUsage_KeyboardLeftControl,
      CONTROL_R = kHIDUsage_KeyboardRightControl,
      OPTION_L  = kHIDUsage_KeyboardLeftAlt,
      OPTION_R  = kHIDUsage_KeyboardRightAlt,
      SHIFT_L   = kHIDUsage_KeyboardLeftShift,
      SHIFT_R   = kHIDUsage_KeyboardRightShift,
    };
    static Value bridgeKeyindexToValue(int bridgeKeyIndex) {
      switch (bridgeKeyIndex) {
        case BRIDGE_KEY_INDEX_CAPSLOCK:  return CAPSLOCK;
        case BRIDGE_KEY_INDEX_JIS_KANA:  return JIS_KANA;
        case BRIDGE_KEY_INDEX_JIS_NFER:  return JIS_NFER;
        case BRIDGE_KEY_INDEX_JIS_XFER:  return JIS_XFER;
        case BRIDGE_KEY_INDEX_COMMAND_L: return COMMAND_L;
        case BRIDGE_KEY_INDEX_COMMAND_R: return COMMAND_R;
        case BRIDGE_KEY_INDEX_CONTROL_L: return CONTROL_L;
        case BRIDGE_KEY_INDEX_CONTROL_R: return CONTROL_R;
        case BRIDGE_KEY_INDEX_OPTION_L:  return OPTION_L;
        case BRIDGE_KEY_INDEX_OPTION_R:  return OPTION_R;
        case BRIDGE_KEY_INDEX_SHIFT_L:   return SHIFT_L;
        case BRIDGE_KEY_INDEX_SHIFT_R:   return SHIFT_R;
      }
      return NONE;
    }
  };
  enum {
    MAXNUM_KEYBOARD = 16,
  };

  // ------------------------------------------------------------
  class HookedKeyboard {
  public:
    HookedKeyboard(void) : kbd_(NULL) {}

    void initialize(IOHIKeyboard* p);
    void terminate(void);
    void refresh(void);
    IOHIKeyboard* get(void) { return kbd_; }

  private:
    IOHIKeyboard* kbd_;
    unsigned int originalKeyCode_[BRIDGE_KEY_INDEX__END__];
  };

  // ------------------------------------------------------------
  static HookedKeyboard* new_hookedKeyboard(void);
  static HookedKeyboard* search_hookedKeyboard(const IOHIKeyboard* kbd);

  static bool IOHIKeyboard_gIOMatchedNotification_callback(void* target, void* refCon, IOService* newService, IONotifier* notifier);
  static bool IOHIKeyboard_gIOTerminatedNotification_callback(void* target, void* refCon, IOService* newService, IONotifier* notifier);

  static bool isTargetDevice(IOHIKeyboard* kbd);

  static bool customizeKeyMap(IOHIKeyboard* kbd);
  static bool restoreKeyMap(IOHIKeyboard* kbd);

  static HookedKeyboard hookedKeyboard_[MAXNUM_KEYBOARD];
  static BridgeUserClientStruct configuration_;

  IONotifier* notifier_hookKeyboard_;
  IONotifier* notifier_unhookKeyboard_;
};

#endif
