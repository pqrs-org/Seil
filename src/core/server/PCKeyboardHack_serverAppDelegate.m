//
//  PCKeyboardHack_serverAppDelegate.m
//  PCKeyboardHack_server
//
//  Created by Takayama Fumihiko on 09/11/28.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PCKeyboardHack_serverAppDelegate.h"
#import "PCKeyboardHackKeys.h"
#import "PCKeyboardHackNSDistributedNotificationCenter.h"
#import "UserClient_userspace.h"
#import "PreferencesManager.h"
#include "bridge.h"

@implementation PCKeyboardHack_serverAppDelegate

@synthesize window;

- (void) send_config_to_kext {
  PreferencesManager* preferencesmanager = [PreferencesManager getInstance];

  struct BridgeConfig bridgeconfig;
  memset(&bridgeconfig, 0, sizeof(bridgeconfig));

  bridgeconfig.version = BRIDGE_CONFIG_VERSION;

  bridgeconfig.config[BRIDGE_KEY_INDEX_CAPSLOCK].enabled  = [preferencesmanager value:@"enable_capslock"];
  bridgeconfig.config[BRIDGE_KEY_INDEX_CAPSLOCK].keycode  = [preferencesmanager value:@"keycode_capslock"];

  bridgeconfig.config[BRIDGE_KEY_INDEX_JIS_KANA].enabled  = [preferencesmanager value:@"enable_jis_kana"];
  bridgeconfig.config[BRIDGE_KEY_INDEX_JIS_KANA].keycode  = [preferencesmanager value:@"keycode_jis_kana"];

  bridgeconfig.config[BRIDGE_KEY_INDEX_JIS_NFER].enabled  = [preferencesmanager value:@"enable_jis_nfer"];
  bridgeconfig.config[BRIDGE_KEY_INDEX_JIS_NFER].keycode  = [preferencesmanager value:@"keycode_jis_nfer"];

  bridgeconfig.config[BRIDGE_KEY_INDEX_JIS_XFER].enabled  = [preferencesmanager value:@"enable_jis_xfer"];
  bridgeconfig.config[BRIDGE_KEY_INDEX_JIS_XFER].keycode  = [preferencesmanager value:@"keycode_jis_xfer"];

  bridgeconfig.config[BRIDGE_KEY_INDEX_COMMAND_L].enabled = [preferencesmanager value:@"enable_command_l"];
  bridgeconfig.config[BRIDGE_KEY_INDEX_COMMAND_L].keycode = [preferencesmanager value:@"keycode_command_l"];

  bridgeconfig.config[BRIDGE_KEY_INDEX_COMMAND_R].enabled = [preferencesmanager value:@"enable_command_r"];
  bridgeconfig.config[BRIDGE_KEY_INDEX_COMMAND_R].keycode = [preferencesmanager value:@"keycode_command_r"];

  bridgeconfig.config[BRIDGE_KEY_INDEX_CONTROL_L].enabled = [preferencesmanager value:@"enable_control_l"];
  bridgeconfig.config[BRIDGE_KEY_INDEX_CONTROL_L].keycode = [preferencesmanager value:@"keycode_control_l"];

  bridgeconfig.config[BRIDGE_KEY_INDEX_CONTROL_R].enabled = [preferencesmanager value:@"enable_control_r"];
  bridgeconfig.config[BRIDGE_KEY_INDEX_CONTROL_R].keycode = [preferencesmanager value:@"keycode_control_r"];

  bridgeconfig.config[BRIDGE_KEY_INDEX_OPTION_L].enabled  = [preferencesmanager value:@"enable_option_l"];
  bridgeconfig.config[BRIDGE_KEY_INDEX_OPTION_L].keycode  = [preferencesmanager value:@"keycode_option_l"];

  bridgeconfig.config[BRIDGE_KEY_INDEX_OPTION_R].enabled  = [preferencesmanager value:@"enable_option_r"];
  bridgeconfig.config[BRIDGE_KEY_INDEX_OPTION_R].keycode  = [preferencesmanager value:@"keycode_option_r"];

  bridgeconfig.config[BRIDGE_KEY_INDEX_SHIFT_L].enabled   = [preferencesmanager value:@"enable_shift_l"];
  bridgeconfig.config[BRIDGE_KEY_INDEX_SHIFT_L].keycode   = [preferencesmanager value:@"keycode_shift_l"];

  bridgeconfig.config[BRIDGE_KEY_INDEX_SHIFT_R].enabled   = [preferencesmanager value:@"enable_shift_r"];
  bridgeconfig.config[BRIDGE_KEY_INDEX_SHIFT_R].keycode   = [preferencesmanager value:@"keycode_shift_r"];

  bridgeconfig.config[BRIDGE_KEY_INDEX_ESCAPE].enabled    = [preferencesmanager value:@"enable_escape"];
  bridgeconfig.config[BRIDGE_KEY_INDEX_ESCAPE].keycode    = [preferencesmanager value:@"keycode_escape"];

  bridgeconfig.config[BRIDGE_KEY_INDEX_DELETE].enabled    = [preferencesmanager value:@"enable_delete"];
  bridgeconfig.config[BRIDGE_KEY_INDEX_DELETE].keycode    = [preferencesmanager value:@"keycode_delete"];

  bridgeconfig.config[BRIDGE_KEY_INDEX_RETURN].enabled    = [preferencesmanager value:@"enable_return"];
  bridgeconfig.config[BRIDGE_KEY_INDEX_RETURN].keycode    = [preferencesmanager value:@"keycode_return"];

  bridgeconfig.config[BRIDGE_KEY_INDEX_ENTER].enabled     = [preferencesmanager value:@"enable_enter"];
  bridgeconfig.config[BRIDGE_KEY_INDEX_ENTER].keycode     = [preferencesmanager value:@"keycode_enter"];

  struct BridgeUserClientStruct bridgestruct;
  bridgestruct.data   = (uintptr_t)(&bridgeconfig);
  bridgestruct.size   = sizeof(bridgeconfig);
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
- (void) distributedObserver_PreferencesChanged:(NSNotification*)notification {
  // [NSAutoreleasePool drain] is never called from NSDistributedNotificationCenter.
  // Therefore, we need to make own NSAutoreleasePool.
  NSAutoreleasePool* pool = [NSAutoreleasePool new];
  {
    [self send_config_to_kext];
  }
  [pool drain];
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
- (NSString*) getFeedURL
{
  PreferencesManager* preferencesmanager = [PreferencesManager getInstance];

  NSInteger checkupdate = [preferencesmanager checkForUpdatesMode];

  // ----------------------------------------
  // check nothing.
  if (checkupdate == 0) {
    return nil;
  }

  // ----------------------------------------
  // check beta & stable releases.

  // Once we check appcast.xml, SUFeedURL is stored in a user's preference file.
  // So that Sparkle gives priority to a preference over Info.plist,
  // we overwrite SUFeedURL here.
  if (checkupdate == 2) {
    return @"http://pqrs.org/macosx/keyremap4macbook/files/PCKeyboardHack-appcast-devel.xml";
  }

  return @"http://pqrs.org/macosx/keyremap4macbook/files/PCKeyboardHack-appcast.xml";
}

- (void) checkForUpdates:(BOOL)isBackground
{
  NSString* url = [self getFeedURL];
  if (! url) {
    NSLog(@"skip checkForUpdates");
    return;
  }
  [suupdater_ setFeedURL:[NSURL URLWithString:url]];

  NSLog(@"checkForUpdates %@", url);
  if (isBackground) {
    [suupdater_ checkForUpdatesInBackground];
  } else {
    [suupdater_ checkForUpdates:nil];
  }
}

- (void) distributedObserver_checkForUpdates:(NSNotification*)aNotification
{
  // [NSAutoreleasePool drain] is never called from NSDistributedNotificationCenter.
  // Therefore, we need to make own NSAutoreleasePool.
  NSAutoreleasePool* pool = [NSAutoreleasePool new];
  {
    [self checkForUpdates:NO];
  }
  [pool drain];
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

  [org_pqrs_PCKeyboardHack_NSDistributedNotificationCenter addObserver:self
                                                              selector:@selector(distributedObserver_PreferencesChanged:)
                                                                  name:kPCKeyboardHackPreferencesChangedNotification];

  [org_pqrs_PCKeyboardHack_NSDistributedNotificationCenter addObserver:self
                                                              selector:@selector(distributedObserver_checkForUpdates:)
                                                                  name:kPCKeyboardHackCheckForUpdatesNotification];
  [self checkForUpdates:YES];
}

- (void) dealloc
{
  [org_pqrs_PCKeyboardHack_NSDistributedNotificationCenter removeObserver:self];
  [[NSNotificationCenter defaultCenter] removeObserver:self];

  [super dealloc];
}

@end
