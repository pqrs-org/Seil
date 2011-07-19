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
  BRIDGE_USERCLIENT_SYNCHRONIZED_COMMUNICATION_RETURN_SUCCESS = 0,
  BRIDGE_USERCLIENT_SYNCHRONIZED_COMMUNICATION_RETURN_ERROR_GENERIC = 1,
};

// 64bit alignment.
struct BridgeUserClientStruct {
  uint8_t capslock_enabled;
  uint8_t capslock_keycode;

  uint8_t jis_xfer_enabled;
  uint8_t jis_xfer_keycode;

  uint8_t jis_nfer_enabled;
  uint8_t jis_nfer_keycode;

  uint8_t jis_kana_enabled;
  uint8_t jis_kana_keycode;
};
// STATIC_ASSERT for sizeof(struct BridgeUserClientStruct).
// We need to make this value same in kext and userspace.
enum { STATIC_ASSERT__sizeof_BridgeUserClientStruct = 1 / (sizeof(struct BridgeUserClientStruct) == 8) };

#endif
