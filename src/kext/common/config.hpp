#ifndef CONFIG_HPP
#define CONFIG_HPP

#include "keymap.hpp"

namespace org_pqrs_PCKeyboardHack {
  class Config {
  public:
    int enable_f1;
    int enable_f2;
    int enable_f3;
    int enable_f4;
    int enable_f5;
    int enable_jis_xfer;
    int enable_jis_nfer;
    int enable_jis_kana;
    int keycode_f1;
    int keycode_f2;
    int keycode_f3;
    int keycode_f4;
    int keycode_f5;
    int keycode_jis_xfer;
    int keycode_jis_nfer;
    int keycode_jis_kana;

    Config(void) {
      keycode_f1 = KeyMapCode::F1;
      keycode_f2 = KeyMapCode::F2;
      keycode_f3 = KeyMapCode::VOLUME_MUTE;
      keycode_f4 = KeyMapCode::VOLUME_DOWN;
      keycode_f5 = KeyMapCode::VOLUME_UP;
      keycode_jis_xfer = KeyMapCode::JIS_KANA;
      keycode_jis_nfer = KeyMapCode::JIS_EISUU;
      keycode_jis_kana = KeyMapCode::COMMAND_R;
    }
  };
  extern Config config;

  void sysctl_register(void);
  void sysctl_unregister(void);
}

#endif
