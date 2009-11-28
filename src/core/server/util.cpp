#include <pthread.h>
#include <sys/types.h>
#include <sys/sysctl.h>
#include <stdlib.h>
#include <string>
#include "util.h"

namespace {
  Util::Mutex mutex_sysctl;
}

void
sysctl_reset(void)
{
  Util::Mutex::ScopedLock lk(mutex_sysctl);

  system("/Library/org.pqrs/PCKeyboardHack/bin/PCKeyboardHack_sysctl_reset terminate");
}

void
sysctl_load(void)
{
  Util::Mutex::ScopedLock lk(mutex_sysctl);

  // --------------------------------------------------
  // check already initialized
  const char *name = "pckeyboardhack.initialized";

  int value;
  size_t len = sizeof(value);
  int error = sysctlbyname(name, &value, &len, NULL, 0);
  if (error) return;
  if (value != 0) return;

  // --------------------------------------------------
  int exitstatus;
  exitstatus = system("/Library/org.pqrs/PCKeyboardHack/bin/PCKeyboardHack_sysctl_reset");
  if (exitstatus != 0) return;

  exitstatus = system("/Library/org.pqrs/PCKeyboardHack/bin/PCKeyboardHack_sysctl_set initialized 1");
  if (exitstatus != 0) return;

  exitstatus = system("/Library/org.pqrs/PCKeyboardHack/bin/PCKeyboardHack_sysctl_ctl load");
  if (exitstatus != 0) return;
}
