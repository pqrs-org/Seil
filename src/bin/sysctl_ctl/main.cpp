#include <sys/time.h>
#include <sys/types.h>
#include <sys/sysctl.h>
#include <stdio.h>
#include <stdlib.h>

#include <iostream>
#include <fstream>
#include <map>

#include <CoreFoundation/CoreFoundation.h>

namespace {
  CFStringRef applicationID = CFSTR("org.pqrs.PCKeyboardHack");

  // ============================================================
  // SAVE & LOAD
  CFMutableDictionaryRef dict_sysctl = NULL;
  std::map<std::string, int> map_reset;

  void
  save(const char* name)
  {
    if (! dict_sysctl) return;

    char entry[512];
    snprintf(entry, sizeof(entry), "pckeyboardhack.%s", name);

    int value;
    size_t len = sizeof(value);
    if (sysctlbyname(entry, &value, &len, NULL, 0) == -1) return;

    CFStringRef key = CFStringCreateWithCString(NULL, name, kCFStringEncodingUTF8);
    CFNumberRef val = CFNumberCreate(NULL, kCFNumberIntType, &value);

    std::map<std::string, int>::iterator it = map_reset.find(name);
    if (it == map_reset.end()) return;
    CFNumberRef defaultval = CFNumberCreate(NULL, kCFNumberIntType, &(it->second));

    if (CFNumberCompare(val, defaultval, NULL) != 0) {
      CFDictionarySetValue(dict_sysctl, key, val);
    }
  }

  void
  load(const char* name)
  {
    if (! dict_sysctl) return;
    CFStringRef key = CFStringCreateWithCString(NULL, name, kCFStringEncodingUTF8);

    CFNumberRef val = reinterpret_cast<CFNumberRef>(CFDictionaryGetValue(dict_sysctl, key));
    if (! val) return;

    int value;
    if (! CFNumberGetValue(val, kCFNumberIntType, &value)) return;

    char cmd[512];
    snprintf(cmd, sizeof(cmd), "/Library/org.pqrs/PCKeyboardHack/bin/PCKeyboardHack_sysctl_set %s %d", name, value);
    system(cmd);
  }

  void
  scanLines(const char* filename, void (* func)(const char*))
  {
    std::ifstream ifs(filename);
    if (! ifs) return;

    while (! ifs.eof()) {
      char line[512];

      ifs.getline(line, sizeof(line));

      const char* tag[] = { "enable", "keycode", NULL };
      for (int i = 0;; ++i) {
        if (tag[i] == NULL) break;

        char sysctl_begin[512];
        char sysctl_end[512];
        snprintf(sysctl_begin, sizeof(sysctl_begin), "<%s>", tag[i]);
        snprintf(sysctl_end, sizeof(sysctl_end), "</%s>", tag[i]);

        char* begin = strstr(line, sysctl_begin);
        if (! begin) continue;
        char* end = strstr(line, sysctl_end);
        if (! end) continue;

        begin += strlen(sysctl_begin);
        *end = '\0';

        func(begin);
      }
    }
  }

  bool
  makeMapReset(void)
  {
    std::ifstream ifs("/Library/org.pqrs/PCKeyboardHack/share/reset");
    if (! ifs) return false;

    while (! ifs.eof()) {
      char line[512];

      ifs.getline(line, sizeof(line));

      char* p = strchr(line, ' ');
      if (! p) continue;
      *p = '\0';

      int value = atoi(p + 1);

      map_reset[line] = value;
    }

    return true;
  }

  bool
  saveToFile(const char** targetFiles)
  {
    if (! makeMapReset()) return false;

    dict_sysctl = CFDictionaryCreateMutable(NULL, 0, NULL, NULL);
    if (! dict_sysctl) return false;

    for (int i = 0;; ++i) {
      const char* filename = targetFiles[i];
      if (! filename) break;
      scanLines(filename, save);
    }
    CFPreferencesSetAppValue(CFSTR("sysctl"), dict_sysctl, applicationID);

    CFRelease(dict_sysctl); dict_sysctl = NULL;
    return true;
  }

  bool
  loadFromFile(const char** targetFiles)
  {
    dict_sysctl = reinterpret_cast<CFMutableDictionaryRef>(const_cast<void*>(CFPreferencesCopyAppValue(CFSTR("sysctl"), applicationID)));
    if (! dict_sysctl) return false;

    for (int i = 0;; ++i) {
      const char* filename = targetFiles[i];
      if (! filename) break;
      scanLines(filename, load);
    }

    CFRelease(dict_sysctl); dict_sysctl = NULL;
    return true;
  }
}


int
main(int argc, char** argv)
{
  if (argc == 1) {
    fprintf(stderr, "Usage: %s (save|load) [params]\n", argv[0]);
    return 1;
  }

  bool isSuccess = false;
  if ((strcmp(argv[1], "save") == 0) || (strcmp(argv[1], "load") == 0)) {
    const char* targetFiles[] = {
      "/Library/org.pqrs/PCKeyboardHack/prefpane/sysctl.xml",
      NULL,
    };
    if (strcmp(argv[1], "save") == 0) {
      isSuccess = saveToFile(targetFiles);
    }
    if (strcmp(argv[1], "load") == 0) {
      system("/Library/org.pqrs/PCKeyboardHack/bin/PCKeyboardHack_sysctl_reset");
      isSuccess = loadFromFile(targetFiles);
    }
  }

  CFPreferencesAppSynchronize(applicationID);

  if (isSuccess) {
    fprintf(stderr, "[DONE]\n");
  } else {
    fprintf(stderr, "[ERROR]\n");
  }

  return 0;
}
