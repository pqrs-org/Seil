#pragma once

#include <mach/mach_types.h>
#include <sys/types.h>

enum {
  BRIDGE_USERCLIENT_OPEN,
  BRIDGE_USERCLIENT_CLOSE,
  BRIDGE_USERCLIENT_SYNCHRONIZED_COMMUNICATION,
  BRIDGE_USERCLIENT_NOTIFICATION_FROM_KEXT,
  BRIDGE_USERCLIENT__END__,
};

enum {
  BRIDGE_USERCLIENT_OPEN_RETURN_SUCCESS = 0,
  BRIDGE_USERCLIENT_OPEN_RETURN_ERROR_GENERIC = 1,
  BRIDGE_USERCLIENT_OPEN_RETURN_ERROR_BRIDGE_VERSION_MISMATCH = 2,
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
  struct {
    uint8_t enabled;
    uint8_t keycode;
  } config[BRIDGE_KEY_INDEX__END__];
};
enum { STATIC_ASSERT__sizeof_BridgeConfig = 1 / (sizeof(struct BridgeConfig) == BRIDGE_KEY_INDEX__END__ * 2) };
