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
  namespace KeyMapCode {
    // see Cosmo_USB2ADB.c
    enum KeyMapCode {
      A = 0, // 0x00
      E = 14, //0x0e

      DELETE = 51, // 0x33
      FORWARD_DELETE = 117, // 0x75
      COMMAND_R = 54, // 0x36
      COMMAND_L = 55, // 0x37

      JIS_KANA = 104, // 0x68
      JIS_EISUU = 102, // 0x66

      F1 = 122, // 0x7a
      F2 = 120, // 0x78
      F3 = 99, // 0x63
      F4 = 118, // 0x76
      F5 = 96, // 0x60

      VOLUME_UP = 72, // 0x48
      VOLUME_DOWN = 73, // 0x49
      VOLUME_MUTE = 74, // 0x4a
    };
  }
}

#endif
