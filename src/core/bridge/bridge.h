#ifndef BRIDGE_H
#define BRIDGE_H

#include <sys/types.h>
#include <mach/mach_types.h>

enum {
  // Version 1: initial version.
  BRIDGE_CONFIG_VERSION = 1,
};

enum {
  BRIDGE_USERCLIENT_OPEN,
  BRIDGE_USERCLIENT_CLOSE,
  BRIDGE_USERCLIENT_SYNCHRONIZED_COMMUNICATION,
  BRIDGE_USERCLIENT__END__,
};

enum {
  BRIDGE_KEY_INDEX_CAPSLOCK,
  BRIDGE_KEY_INDEX_JIS_KANA,
  BRIDGE_KEY_INDEX_JIS_NFER,
  BRIDGE_KEY_INDEX_JIS_XFER,
  BRIDGE_KEY_INDEX_COMMAND_L,
  BRIDGE_KEY_INDEX_COMMAND_R,
  BRIDGE_KEY_INDEX_CONTROL_L,
  BRIDGE_KEY_INDEX_CONTROL_R,
  BRIDGE_KEY_INDEX_OPTION_L,
  BRIDGE_KEY_INDEX_OPTION_R,
  BRIDGE_KEY_INDEX_SHIFT_L,
  BRIDGE_KEY_INDEX_SHIFT_R,
  BRIDGE_KEY_INDEX_ESCAPE,
  BRIDGE_KEY_INDEX_DELETE,
  BRIDGE_KEY_INDEX_RETURN,
  BRIDGE_KEY_INDEX_ENTER,
  BRIDGE_KEY_INDEX__END__,
};

// 64bit alignment.
struct BridgeUserClientStruct {
  mach_vm_address_t data;
  mach_vm_size_t size; // size of data
};
// STATIC_ASSERT for sizeof(struct BridgeUserClientStruct).
// We need to make this value same in kext and userspace.
enum { STATIC_ASSERT__sizeof_BridgeUserClientStruct = 1 / (sizeof(struct BridgeUserClientStruct) == 16) };

struct BridgeConfig {
  uint8_t version;

  struct {
    uint8_t enabled;
    uint8_t keycode;
  } config[BRIDGE_KEY_INDEX__END__];
};
enum { STATIC_ASSERT__sizeof_BridgeConfig = 1 / (sizeof(struct BridgeConfig) == 1 + BRIDGE_KEY_INDEX__END__ * 2) };

#endif
