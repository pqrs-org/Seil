#ifndef CONFIG_HPP
#define CONFIG_HPP

#include "keymap.hpp"

namespace org_pqrs_PCKeyboardHack {
  class Config {
  public:
#include "generate/output/include.config.hpp"

    Config(void) {
      keycode_capslock = KeyMapCode::DELETE;
      keycode_control_l = KeyMapCode::COMMAND_L;
      keycode_control_r = KeyMapCode::COMMAND_R;
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
