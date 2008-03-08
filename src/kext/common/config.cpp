#include <sys/types.h>
#include <sys/sysctl.h>

#include "base.hpp"
#include "PCKeyboardHack.hpp"
#include "config.hpp"
#include "version.hpp"

namespace org_pqrs_PCKeyboardHack {
  Config config;

  int sysctlFunc SYSCTL_HANDLER_ARGS
  {
    int error = sysctl_handle_int(oidp, oidp->oid_arg1, oidp->oid_arg2,  req);
    if (! error && req->newptr) {
      org_pqrs_driver_PCKeyboardHack::customizeAllKeymap();
    }
    return error;
  }

  // ----------------------------------------------------------------------
  // SYSCTL staff
  // http://developer.apple.com/documentation/Darwin/Conceptual/KernelProgramming/boundaries/chapter_14_section_7.html#//apple_ref/doc/uid/TP30000905-CH217-TPXREF116
  SYSCTL_DECL(_pckeyboardhack);
  SYSCTL_NODE(, OID_AUTO, pckeyboardhack, CTLFLAG_RW, 0, "PCKeyboardHack");

#include "generate/output/include.config_SYSCTL.cpp"

  SYSCTL_STRING(_pckeyboardhack, OID_AUTO, version, CTLFLAG_RD, config_version, 0, "");

  // ----------------------------------------------------------------------
  void
  sysctl_register(void)
  {
    sysctl_register_oid(&sysctl__pckeyboardhack);

#include "generate/output/include.config_register.cpp"

    sysctl_register_oid(&sysctl__pckeyboardhack_version);
  }

  void
  sysctl_unregister(void)
  {
    sysctl_unregister_oid(&sysctl__pckeyboardhack);

#include "generate/output/include.config_unregister.cpp"

    sysctl_unregister_oid(&sysctl__pckeyboardhack_version);
  }
}
