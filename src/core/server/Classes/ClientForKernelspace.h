// -*- Mode: objc; Coding: utf-8; indent-tabs-mode: nil; -*-

@import Cocoa;
#include "bridge.h"

@interface ClientForKernelspace : NSObject

- (void)refresh_connection_with_retry;
- (void)disconnect_from_kext;
- (void)send_config_to_kext;

@end
