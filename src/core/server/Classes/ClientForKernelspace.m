#import "ClientForKernelspace.h"
#import "NotificationKeys.h"
#import "PreferencesManager.h"
#import "UserClient_userspace.h"

@interface ClientForKernelspace ()

@property(weak) IBOutlet PreferencesManager* preferencesManager;

@property io_async_ref64_t* asyncref;
@property UserClient_userspace* userClient_userspace;
@property NSTimer* timer;
@property int retryCounter;

@end

@implementation ClientForKernelspace

static void static_callback_NotificationFromKext(void* refcon, IOReturn result, uint32_t type, uint32_t option) {}

- (void)observer_PreferencesChanged:(NSNotification*)notification {
  dispatch_async(dispatch_get_main_queue(), ^{
    [self send_config_to_kext];
  });
}

- (id)init {
  self = [super init];

  if (self) {
    self.asyncref = (io_async_ref64_t*)(malloc(sizeof(io_async_ref64_t)));

    (*(self.asyncref))[kIOAsyncCalloutFuncIndex] = (io_user_reference_t)(static_callback_NotificationFromKext);
    (*(self.asyncref))[kIOAsyncCalloutRefconIndex] = (io_user_reference_t)(self);

    self.userClient_userspace = [[UserClient_userspace alloc] init:self.asyncref];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(observer_PreferencesChanged:)
                                                 name:kPreferencesChangedNotification
                                               object:nil];
  }

  return self;
}

- (void)dealloc {
  [self.timer invalidate];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)refresh_connection_with_retry {
  @synchronized(self) {
    // [UserClient_userspace connect_to_kext] may fail by kIOReturnExclusiveAccess
    // when connect_to_kext is called in NSWorkspaceSessionDidBecomeActiveNotification.
    // So, we retry the connection some times.
    //
    // Try one minute
    // (There are few seconds between kext::init and registerService is called.
    // So we need to wait for a while.)

    [self.timer invalidate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                  target:self
                                                selector:@selector(timerFireMethod:)
                                                userInfo:nil
                                                 repeats:YES];
    self.retryCounter = 0;
    [self.timer fire];
  }
}

- (void)timerFireMethod:(NSTimer*)timer {
  dispatch_async(dispatch_get_main_queue(), ^{
    @synchronized(self) {
      if (![timer isValid]) {
        // disconnect_from_kext is already called.
        // return immediately.
        return;
      }

      @try {
        if ([self.userClient_userspace refresh_connection]) {
          // connected

          [timer invalidate];
          [self send_config_to_kext];
          return;

        } else {
          // retry

          ++(self.retryCounter);
          if (self.retryCounter > 120) {
            [timer invalidate];

            NSAlert* alert = [NSAlert new];
            [alert setMessageText:@"Seil Alert"];
            [alert addButtonWithTitle:@"Close"];
            [alert setInformativeText:@"Seil cannot connect with kernel extension.\nPlease restart your system in order to solve the problem.\n"];
            [alert runModal];

            return;
          }
        }

      } @catch (NSException* e) {
        // unrecoverable error occurred.

        [timer invalidate];

        NSAlert* alert = [NSAlert new];
        [alert setMessageText:@"Seil Alert"];
        [alert addButtonWithTitle:@"Close"];
        [alert setInformativeText:[e reason]];
        [alert runModal];

        return;
      }
    }
  });
}

- (void)disconnect_from_kext {
  @synchronized(self) {
    [self.timer invalidate];
    [self.userClient_userspace disconnect_from_kext];
  }
}

- (void)send_config_to_kext {
  struct BridgeConfig bridgeconfig;
  memset(&bridgeconfig, 0, sizeof(bridgeconfig));

#include "bridgeconfig_config.h"

  struct BridgeUserClientStruct bridgestruct;
  bridgestruct.type = BRIDGE_USERCLIENT_TYPE_SET_CONFIG;
  bridgestruct.option = 0;
  bridgestruct.data = (uintptr_t)(&bridgeconfig);
  bridgestruct.size = sizeof(bridgeconfig);
  [self.userClient_userspace synchronized_communication:&bridgestruct];
}

@end
