#ifndef KEYMAP_HPP
#define KEYMAP_HPP

namespace org_pqrs_PCKeyboardHack {
  namespace KeyMapIndex {
    // see IOHIDUsageTables.h or http://www2d.biglobe.ne.jp/~msyk/keyboard/layout/usbkeycode.html
    enum KeyMapIndex {
      A = 0x04,
      E = 0x08,

      CAPSLOCK = 0x39,
      DELETE = 0x2a,

      CONTROL_L = 0xe0,
      CONTROL_R = 0xe4,

      JIS_KANA = 0x88,
      JIS_XFER = 0x8a,
      JIS_NFER = 0x8b,

      F1 = 0x3a,
      F2 = 0x3b,
      F3 = 0x3c,
      F4 = 0x3d,
      F5 = 0x3e,
    };
  }
}

#endif
