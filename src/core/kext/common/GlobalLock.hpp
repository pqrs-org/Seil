#pragma once

namespace org_pqrs_Seil {
class GlobalLock {
public:
  static void initialize(void);
  static void terminate(void);

  class ScopedLock {
  public:
    ScopedLock(void);
    ~ScopedLock(void);
    bool operator!(void)const;

  private:
    IOLock* lock_;
  };

  class ScopedUnlock {
  public:
    ScopedUnlock(void);
    ~ScopedUnlock(void);
    bool operator!(void)const;

  private:
    IOLock* lock_;
  };

private:
  static IOLock* lock_;
};
}
