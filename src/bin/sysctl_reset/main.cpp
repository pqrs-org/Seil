#include <sys/types.h>
#include <sys/sysctl.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include <iostream>
#include <fstream>

#include <CoreFoundation/CoreFoundation.h>
#include <SystemConfiguration/SystemConfiguration.h>

namespace {
  bool
  verifyUser(void)
  {
    uid_t consoleUID;
    CFStringRef result = SCDynamicStoreCopyConsoleUser(NULL, &consoleUID, NULL);
    // TRUE if no user is logged in
    if (result == NULL) return true;

    bool isvalid = false;
    // If the current console user is "loginwindow", treat that as TRUE.
    if (CFEqual(result, CFSTR("loginwindow"))) {
      isvalid = true;
    } else {
      isvalid = (getuid() == consoleUID);
    }
    CFRelease(result);

    return isvalid;
  }

  bool
  isKextExists(void)
  {
    const char* name = "pckeyboardhack.initialized";

    int value;
    size_t len = sizeof(value);
    int error = sysctlbyname(name, &value, &len, NULL, 0);
    if (error) return false;

    return true;
  }

  void
  set(const char* name, int value)
  {
    char entry[512];
    snprintf(entry, sizeof(entry), "pckeyboardhack.%s", name);

    size_t oldlen = 0;
    size_t newlen = sizeof(value);
    if (sysctlbyname(entry, NULL, &oldlen, &value, newlen) == -1) {
      perror("sysctl_reset set");
    }
  }
}


int
main(int argc, char** argv)
{
  if (! verifyUser()) {
    return 1;
  }

  if (! isKextExists()) {
    std::cerr << "PCKeyboardHack: kext is not yet loaded" << std::endl;
    return 1;
  }

  std::ifstream ifs("/Library/org.pqrs/PCKeyboardHack/share/reset");
  if (! ifs) return 1;

  while (! ifs.eof()) {
    char line[512];

    ifs.getline(line, sizeof(line));

    char* p = strchr(line, ' ');
    if (! p) continue;
    *p = '\0';

    set(line, atoi(p + 1));
  }

  if (argc == 2 && strcmp(argv[1], "terminate") == 0) {
    set("initialized", 0);
  }

  return 0;
}
