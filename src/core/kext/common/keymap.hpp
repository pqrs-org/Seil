#ifndef KEYMAP_HPP
#define KEYMAP_HPP

namespace org_pqrs_PCKeyboardHack {
  namespace KeyMapIndex {
    // see IOHIDUsageTables.h or http://www2d.biglobe.ne.jp/~msyk/keyboard/layout/usbkeycode.html
    enum KeyMapIndex {
      CAPSLOCK = 0x39,
      JIS_KANA = 0x88,
      JIS_XFER = 0x8a,
      JIS_NFER = 0x8b,
    };
  }
}

#endif
