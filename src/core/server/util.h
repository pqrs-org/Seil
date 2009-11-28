#ifndef UTIL_H
#define UTIL_H

#ifdef __cplusplus
extern "C" {
#endif

void sysctl_reset(void);
void sysctl_load(void);

#ifdef __cplusplus
namespace Util {
  class Mutex {
  public:
    Mutex(void) {
      pthread_mutex_init(&mutex_, NULL);
    }
    ~Mutex(void) {
      pthread_mutex_destroy(&mutex_);
    }
    int lock(void) {
      return pthread_mutex_lock(&mutex_);
    }
    int unlock(void) {
      return pthread_mutex_unlock(&mutex_);
    }

    class ScopedLock {
    public:
      ScopedLock(Mutex& m) : mutex_(m) {
        mutex_.lock();
      }
      ~ScopedLock(void) {
        mutex_.unlock();
      }
    private:
      Mutex& mutex_;
    };

  private:
    pthread_mutex_t mutex_;
  };

  Mutex mutex_sysctl;
}
#endif

#ifdef __cplusplus
}
#endif

#endif
