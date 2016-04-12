#pragma once

#define IOLOG_DEBUG(...)                               \
  {                                                    \
    if (!org_pqrs_Seil::IOLogWrapper::suppressed()) {  \
      if (Config::get_debug()) {                       \
        IOLog("org.pqrs.Seil --Debug-- " __VA_ARGS__); \
      }                                                \
    }                                                  \
  }
#define IOLOG_DEBUG_POINTING(...)                      \
  {                                                    \
    if (!org_pqrs_Seil::IOLogWrapper::suppressed()) {  \
      if (Config::get_debug_pointing()) {              \
        IOLog("org.pqrs.Seil --Debug-- " __VA_ARGS__); \
      }                                                \
    }                                                  \
  }
#define IOLOG_DEVEL(...)                               \
  {                                                    \
    if (!org_pqrs_Seil::IOLogWrapper::suppressed()) {  \
      if (Config::get_debug_devel()) {                 \
        IOLog("org.pqrs.Seil --Devel-- " __VA_ARGS__); \
      }                                                \
    }                                                  \
  }

#define IOLOG_ERROR(...)                              \
  {                                                   \
    if (!org_pqrs_Seil::IOLogWrapper::suppressed()) { \
      IOLog("org.pqrs.Seil --Error-- " __VA_ARGS__);  \
    }                                                 \
  }

#define IOLOG_INFO(...)                               \
  {                                                   \
    if (!org_pqrs_Seil::IOLogWrapper::suppressed()) { \
      IOLog("org.pqrs.Seil --Info-- " __VA_ARGS__);   \
    }                                                 \
  }

#define IOLOG_WARN(...)                               \
  {                                                   \
    if (!org_pqrs_Seil::IOLogWrapper::suppressed()) { \
      IOLog("org.pqrs.Seil --Warn-- " __VA_ARGS__);   \
    }                                                 \
  }

// ------------------------------------------------------------
namespace org_pqrs_Seil {
class IOLogWrapper {
public:
  static bool suppressed(void) { return suppressed_; }
  static void suppress(bool v) { suppressed_ = v; }

  class ScopedSuppress {
  public:
    ScopedSuppress(void) {
      original = suppressed();
      suppress(true);
    }
    ~ScopedSuppress(void) { suppress(original); }

  private:
    bool original;
  };

private:
  static bool suppressed_;
};
}
