#include <sys/types.h>
#include <sys/sysctl.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>

namespace {
  void sigfunc(int param) {
    system("/Library/org.pqrs/PCKeyboardHack/bin/PCKeyboardHack_sysctl_reset terminate");
    exit(0);
  }
}

int
main()
{
  signal(SIGHUP, sigfunc);
  signal(SIGTERM, sigfunc);

  for (;;) {
    const char *name = "pckeyboardhack.initialized";

    int value;
    size_t len = sizeof(value);
    int error = sysctlbyname(name, &value, &len, NULL, 0);
    if (error) {
      goto nextLoop;
    }
    if (value != 0) {
      goto nextLoop;
    }

    system("/Library/org.pqrs/PCKeyboardHack/bin/PCKeyboardHack_sysctl_reset");
    system("/Library/org.pqrs/PCKeyboardHack/bin/PCKeyboardHack_sysctl_set initialized 1");
    system("/Library/org.pqrs/PCKeyboardHack/bin/PCKeyboardHack_sysctl_ctl load");

  nextLoop:
    sleep(3);
  }

  return 0;
}
