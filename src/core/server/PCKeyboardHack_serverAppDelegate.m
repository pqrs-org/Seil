//
//  PCKeyboardHack_serverAppDelegate.m
//  PCKeyboardHack_server
//
//  Created by Takayama Fumihiko on 09/11/28.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PCKeyboardHack_serverAppDelegate.h"
#import "PCKeyboardHackKeys.h"
#import "UserClient_userspace.h"
#import "PreferencesManager.h"
#include "bridge.h"

@implementation PCKeyboardHack_serverAppDelegate

@synthesize window;

- (void) send_config_to_kext {
  PreferencesManager* preferencesmanager = [PreferencesManager getInstance];

  struct BridgeUserClientStruct bridgestruct;
  memset(&bridgestruct, 0, sizeof(bridgestruct));

  bridgestruct.enabled[BRIDGE_KEY_INDEX_CAPSLOCK]  = [preferencesmanager value:@"enable_capslock"];
  bridgestruct.keycode[BRIDGE_KEY_INDEX_CAPSLOCK]  = [preferencesmanager value:@"keycode_capslock"];

  bridgestruct.enabled[BRIDGE_KEY_INDEX_JIS_KANA]  = [preferencesmanager value:@"enable_jis_kana"];
  bridgestruct.keycode[BRIDGE_KEY_INDEX_JIS_KANA]  = [preferencesmanager value:@"keycode_jis_kana"];

  bridgestruct.enabled[BRIDGE_KEY_INDEX_JIS_NFER]  = [preferencesmanager value:@"enable_jis_nfer"];
  bridgestruct.keycode[BRIDGE_KEY_INDEX_JIS_NFER]  = [preferencesmanager value:@"keycode_jis_nfer"];

  bridgestruct.enabled[BRIDGE_KEY_INDEX_JIS_XFER]  = [preferencesmanager value:@"enable_jis_xfer"];
  bridgestruct.keycode[BRIDGE_KEY_INDEX_JIS_XFER]  = [preferencesmanager value:@"keycode_jis_xfer"];

  bridgestruct.enabled[BRIDGE_KEY_INDEX_COMMAND_L] = [preferencesmanager value:@"enable_command_l"];
  bridgestruct.keycode[BRIDGE_KEY_INDEX_COMMAND_L] = [preferencesmanager value:@"keycode_command_l"];

  bridgestruct.enabled[BRIDGE_KEY_INDEX_COMMAND_R] = [preferencesmanager value:@"enable_command_r"];
  bridgestruct.keycode[BRIDGE_KEY_INDEX_COMMAND_R] = [preferencesmanager value:@"keycode_command_r"];

  bridgestruct.enabled[BRIDGE_KEY_INDEX_CONTROL_L] = [preferencesmanager value:@"enable_control_l"];
  bridgestruct.keycode[BRIDGE_KEY_INDEX_CONTROL_L] = [preferencesmanager value:@"keycode_control_l"];

  bridgestruct.enabled[BRIDGE_KEY_INDEX_CONTROL_R] = [preferencesmanager value:@"enable_control_r"];
  bridgestruct.keycode[BRIDGE_KEY_INDEX_CONTROL_R] = [preferencesmanager value:@"keycode_control_r"];

  bridgestruct.enabled[BRIDGE_KEY_INDEX_OPTION_L]  = [preferencesmanager value:@"enable_option_l"];
  bridgestruct.keycode[BRIDGE_KEY_INDEX_OPTION_L]  = [preferencesmanager value:@"keycode_option_l"];

  bridgestruct.enabled[BRIDGE_KEY_INDEX_OPTION_R]  = [preferencesmanager value:@"enable_option_r"];
  bridgestruct.keycode[BRIDGE_KEY_INDEX_OPTION_R]  = [preferencesmanager value:@"keycode_option_r"];

  bridgestruct.enabled[BRIDGE_KEY_INDEX_SHIFT_L]   = [preferencesmanager value:@"enable_shift_l"];
  bridgestruct.keycode[BRIDGE_KEY_INDEX_SHIFT_L]   = [preferencesmanager value:@"keycode_shift_l"];

  bridgestruct.enabled[BRIDGE_KEY_INDEX_SHIFT_R]   = [preferencesmanager value:@"enable_shift_r"];
  bridgestruct.keycode[BRIDGE_KEY_INDEX_SHIFT_R]   = [preferencesmanager value:@"keycode_shift_r"];

  [UserClient_userspace synchronized_communication:&bridgestruct];
}

// ------------------------------------------------------------
static void observer_IONotification(void* refcon, io_iterator_t iterator) {
  NSLog(@"observer_IONotification");

  PCKeyboardHack_serverAppDelegate* self = refcon;
  if (! self) {
    NSLog(@"[ERROR] observer_IONotification refcon == nil\n");
    return;
  }

  for (;;) {
    io_object_t obj = IOIteratorNext(iterator);
    if (! obj) break;

    IOObjectRelease(obj);
  }
  // Do not release iterator.

  // = Documentation of IOKit =
  // - Introduction to Accessing Hardware From Applications
  //   - Finding and Accessing Devices
  //
  // In the case of IOServiceAddMatchingNotification, make sure you release the iterator only if you’re also ready to stop receiving notifications:
  // When you release the iterator you receive from IOServiceAddMatchingNotification, you also disable the notification.

  // ------------------------------------------------------------
  // [UserClient_userspace refresh_connection] may fail by kIOReturnExclusiveAccess
  // when NSWorkspaceSessionDidBecomeActiveNotification.
  // So, we retry the connection some times.
  for (int retrycount = 0; retrycount < 10; ++retrycount) {
    [UserClient_userspace refresh_connection];
    if ([UserClient_userspace connected]) break;

    [NSThread sleepForTimeInterval:0.5];
  }

  [self send_config_to_kext];
}

- (void) unregisterIONotification {
  if (notifyport_) {
    if (loopsource_) {
      CFRunLoopSourceInvalidate(loopsource_);
      loopsource_ = nil;
    }
    IONotificationPortDestroy(notifyport_);
    notifyport_ = nil;
  }
}

- (void) registerIONotification {
  [self unregisterIONotification];

  notifyport_ = IONotificationPortCreate(kIOMasterPortDefault);
  if (! notifyport_) {
    NSLog(@"[ERROR] IONotificationPortCreate failed\n");
    return;
  }

  // ----------------------------------------------------------------------
  io_iterator_t it;
  kern_return_t kernResult;

  kernResult = IOServiceAddMatchingNotification(notifyport_,
                                                kIOMatchedNotification,
                                                IOServiceNameMatching("org_pqrs_driver_PCKeyboardHack"),
                                                &observer_IONotification,
                                                self,
                                                &it);
  if (kernResult != kIOReturnSuccess) {
    NSLog(@"[ERROR] IOServiceAddMatchingNotification failed");
    return;
  }
  observer_IONotification(self, it);

  // ----------------------------------------------------------------------
  loopsource_ = IONotificationPortGetRunLoopSource(notifyport_);
  if (! loopsource_) {
    NSLog(@"[ERROR] IONotificationPortGetRunLoopSource failed");
    return;
  }
  CFRunLoopAddSource(CFRunLoopGetCurrent(), loopsource_, kCFRunLoopDefaultMode);
}

// ------------------------------------------------------------
- (void) observer_PreferencesChanged:(NSNotification*)notification {
  [self send_config_to_kext];
}

// ------------------------------------------------------------
- (void) observer_NSWorkspaceSessionDidBecomeActiveNotification:(NSNotification*)notification
{
  NSLog(@"observer_NSWorkspaceSessionDidBecomeActiveNotification");

  [self registerIONotification];
}

- (void) observer_NSWorkspaceSessionDidResignActiveNotification:(NSNotification*)notification
{
  NSLog(@"observer_NSWorkspaceSessionDidResignActiveNotification");

  [self unregisterIONotification];
  [UserClient_userspace disconnect_from_kext];
}

// ------------------------------------------------------------
- (void) applicationDidFinishLaunching:(NSNotification*)aNotification {
  [self registerIONotification];

  // ------------------------------------------------------------
  [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
                                                         selector:@selector(observer_NSWorkspaceSessionDidBecomeActiveNotification:)
                                                             name:NSWorkspaceSessionDidBecomeActiveNotification
                                                           object:nil];

  [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
                                                         selector:@selector(observer_NSWorkspaceSessionDidResignActiveNotification:)
                                                             name:NSWorkspaceSessionDidResignActiveNotification
                                                           object:nil];

  [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                      selector:@selector(observer_PreferencesChanged:)
                                                          name:kPCKeyboardHackPreferencesChangedNotification
                                                        object:kPCKeyboardHackNotificationKey];
}

@end
