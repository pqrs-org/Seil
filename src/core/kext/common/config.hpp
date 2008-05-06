#ifndef CONFIG_HPP
#define CONFIG_HPP

#include "keymap.hpp"

namespace org_pqrs_PCKeyboardHack {
  class Config {
  public:
#include "generate/output/include.config.hpp"

    Config(void) {
#include "generate/output/include.config.default.hpp"
    }
  };
  extern Config config;

  void sysctl_register(void);
  void sysctl_unregister(void);
}

#endif
