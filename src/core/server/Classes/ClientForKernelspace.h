// -*- Mode: objc; Coding: utf-8; indent-tabs-mode: nil; -*-

#import <Cocoa/Cocoa.h>
#include "bridge.h"

@class PreferencesManager;
@class UserClient_userspace;

@interface ClientForKernelspace : NSObject {
  IBOutlet PreferencesManager* preferencesManager_;
}

- (void)refresh_connection_with_retry;
- (void)disconnect_from_kext;
- (void)send_config_to_kext;

@end
