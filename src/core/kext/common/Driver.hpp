// -*- indent-tabs-mode: nil; -*-

#ifndef DRIVER_HPP
#define DRIVER_HPP

#include <IOKit/IOService.h>
#include <IOKit/hidsystem/IOHIDUsageTables.h>
#include <IOKit/hidsystem/IOHIKeyboard.h>

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

  static void setConfiguration(const BridgeConfig& newval);
  static void unsetConfiguration(void);

private:
  // see IOHIDUsageTables.h or http://www2d.biglobe.ne.jp/~msyk/keyboard/layout/usbkeycode.html
  class KeyMapIndex {
  public:
    enum Value {
      NONE               = 0, // NONE must be a unique value in this enum.
#include "KeyMapIndex_Value.hpp"
    };
    static Value bridgeKeyindexToValue(int bridgeKeyIndex) {
      switch (bridgeKeyIndex) {
#include "KeyMapIndex_bridgeKeyindexToValue.hpp"
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
    HookedKeyboard(void) : kbd_(NULL) {
      bzero(originalKeyCode_, sizeof(originalKeyCode_));
    }

    void initialize(IOHIKeyboard* p);
    void terminate(void);
    void refresh(void);
    IOHIKeyboard* get(void) { return kbd_; }

  private:
    void restore(void);

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
  static BridgeConfig configuration_;

  IONotifier* notifier_hookKeyboard_;
  IONotifier* notifier_unhookKeyboard_;
};

#endif
