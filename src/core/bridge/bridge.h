#ifndef BRIDGE_H
#define BRIDGE_H

#include <sys/types.h>
#include <mach/mach_types.h>

enum {
  // Version 1: initial version.
  // Version 2: changed to use autogen code (BRIDGE_KEY_INDEX.h).
  // Version 3: added new keys.
  // Version 4: added new keys. (LANG*)
  BRIDGE_CONFIG_VERSION = 4,
};

enum {
  BRIDGE_USERCLIENT_OPEN,
  BRIDGE_USERCLIENT_CLOSE,
  BRIDGE_USERCLIENT_SYNCHRONIZED_COMMUNICATION,
  BRIDGE_USERCLIENT_NOTIFICATION_FROM_KEXT,
  BRIDGE_USERCLIENT__END__,
};

enum {
  BRIDGE_USERCLIENT_SYNCHRONIZED_COMMUNICATION_RETURN_SUCCESS = 0,
  BRIDGE_USERCLIENT_SYNCHRONIZED_COMMUNICATION_RETURN_ERROR_GENERIC = 1,
};

enum {
  BRIDGE_USERCLIENT_TYPE_NONE,
  BRIDGE_USERCLIENT_TYPE_SET_CONFIG,
};

enum {
#include "BRIDGE_KEY_INDEX.h"
  BRIDGE_KEY_INDEX__END__,
};

// 64bit alignment.
struct BridgeUserClientStruct {
  uint32_t type;
  uint32_t option;
  user_addr_t data;
  user_size_t size;
};
// STATIC_ASSERT for sizeof(struct BridgeUserClientStruct).
// We need to make this value same in kext and userspace.
enum { STATIC_ASSERT__sizeof_BridgeUserClientStruct = 1 / (sizeof(struct BridgeUserClientStruct) == 24) };

struct BridgeConfig {
  uint8_t version;

  struct {
    uint8_t enabled;
    uint8_t keycode;
  } config[BRIDGE_KEY_INDEX__END__];
};
enum { STATIC_ASSERT__sizeof_BridgeConfig = 1 / (sizeof(struct BridgeConfig) == 1 + BRIDGE_KEY_INDEX__END__ * 2) };

#endif
