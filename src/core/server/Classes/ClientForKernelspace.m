#import "ClientForKernelspace.h"
#import "NotificationKeys.h"
#import "PreferencesManager.h"
#import "UserClient_userspace.h"

@implementation ClientForKernelspace

@synthesize userClient_userspace;

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
    userClient_userspace = [UserClient_userspace new];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(observer_PreferencesChanged:)
                                                 name:kPreferencesChangedNotification object:nil];
  }

  return self;
}

- (void) dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [userClient_userspace release];

  [super dealloc];
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

  bridgeconfig.version = BRIDGE_CONFIG_VERSION;

#include "bridgeconfig_config.h"

  struct BridgeUserClientStruct bridgestruct;
  bridgestruct.data   = (uintptr_t)(&bridgeconfig);
  bridgestruct.size   = sizeof(bridgeconfig);
  [userClient_userspace synchronized_communication:&bridgestruct];
}

@end
