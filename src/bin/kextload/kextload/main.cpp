#include <boost/lexical_cast.hpp>
#include <iostream>
#include <string>
#include <sys/utsname.h>
#include <unistd.h>

namespace {
int os_major_version(void) {
  struct utsname un;
  if (uname(&un) != 0) {
    return -1;
  }

  std::string release(un.release);
  auto pos = release.find('.');
  if (pos == std::string::npos) {
    return -1;
  }

  return boost::lexical_cast<int>(release.substr(0, pos));
}

void usage(void) {
  std::cout << "Usage: kextload {load|unload}" << std::endl;
  exit(1);
}
}

int main(int argc, const char* argv[]) {
  if (argc != 2) {
    usage();
  }

  std::string command;
  std::string argument(argv[1]);

  if (argument == "load") {
    int major = os_major_version();
    switch (major) {
    case 13: // OS X 10.9
      command = "/sbin/kextload '/Applications/Seil.app/Contents/Library/Seil.10.9.signed.kext'";
      break;
    case 14: // OS X 10.10
      command = "/sbin/kextload '/Applications/Seil.app/Contents/Library/Seil.10.10.signed.kext'";
      break;
    case 15: // OS X 10.11
      command = "/sbin/kextload '/Applications/Seil.app/Contents/Library/Seil.10.11.signed.kext'";
      break;
    default:
      std::cerr << "Unknown os major version: " << major << std::endl;
      exit(1);
    }

  } else if (argument == "unload") {
    command = "/sbin/kextunload -b org.pqrs.driver.Seil";
  } else {
    usage();
  }

  // We need to call setuid in order to Execute command as root.
  // (rwsr-xr-x permission changes only euid (geteuid). So, we need to change uid by hand.)
  if (setuid(0) != 0) {
    std::cerr << "Failed to setuid(0)." << std::endl;
    exit(1);
  }
  return system(command.c_str());
}
