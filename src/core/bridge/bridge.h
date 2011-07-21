#ifndef BRIDGE_H
#define BRIDGE_H

#include <sys/types.h>
#include <mach/mach_types.h>

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
  BRIDGE_KEY_INDEX__END__,
};

// 64bit alignment.
struct BridgeUserClientStruct {
  uint8_t enabled[BRIDGE_KEY_INDEX__END__];
  uint8_t keycode[BRIDGE_KEY_INDEX__END__];
};
// STATIC_ASSERT for sizeof(struct BridgeUserClientStruct).
// We need to make this value same in kext and userspace.
enum { STATIC_ASSERT__sizeof_BridgeUserClientStruct = 1 / (sizeof(struct BridgeUserClientStruct) == BRIDGE_KEY_INDEX__END__ * 2) };

#endif
