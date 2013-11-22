#import "ClientForKernelspace.h"
#import "NotificationKeys.h"
#import "PreferencesManager.h"
#import "UserClient_userspace.h"

@implementation ClientForKernelspace

@synthesize userClient_userspace;

static void callback_NotificationFromKext(void* refcon, IOReturn result, uint32_t type, uint32_t option)
{}

- (void) observer_PreferencesChanged:(NSNotification*)notification
{
  dispatch_async(dispatch_get_main_queue(), ^{
    [self send_config_to_kext];
  });
}

- (id) init
{
  self = [super init];

  if (self) {
    asyncref_[kIOAsyncCalloutFuncIndex] = (io_user_reference_t)(callback_NotificationFromKext);
    asyncref_[kIOAsyncCalloutRefconIndex] = (io_user_reference_t)(self);

    userClient_userspace = [[UserClient_userspace alloc] init:&asyncref_];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(observer_PreferencesChanged:)
                                                 name:kPreferencesChangedNotification object:nil];
  }

  return self;
}

- (void) dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];

}

- (void) refresh_connection_with_retry
{
  [userClient_userspace refresh_connection_with_retry:10 wait:0.5];
  [self send_config_to_kext];
}

- (void) disconnect_from_kext
{
  [userClient_userspace disconnect_from_kext];
}

- (void) send_config_to_kext
{
  struct BridgeConfig bridgeconfig;
  memset(&bridgeconfig, 0, sizeof(bridgeconfig));

#include "bridgeconfig_config.h"

  struct BridgeUserClientStruct bridgestruct;
  bridgestruct.type   = BRIDGE_USERCLIENT_TYPE_SET_CONFIG;
  bridgestruct.option = 0;
  bridgestruct.data   = (uintptr_t)(&bridgeconfig);
  bridgestruct.size   = sizeof(bridgeconfig);
  [userClient_userspace synchronized_communication:&bridgestruct];
}

@end
