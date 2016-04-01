#import "AppDelegate.h"
#import "ClientForKernelspace.h"
#import "MigrationUtilities.h"
#import "PreferencesKeys.h"
#import "PreferencesWindowController.h"
#import "Relauncher.h"
#import "ServerController.h"
#import "ServerForUserspace.h"
#import "ServerObjects.h"
#import "SessionObserver.h"
#import "StartAtLoginUtilities.h"
#import "Updater.h"
#include "bridge.h"

@interface AppDelegate ()

@property(weak) IBOutlet ServerForUserspace* serverForUserspace;
@property(weak) IBOutlet ClientForKernelspace* clientForKernelspace;
@property(weak) IBOutlet ServerObjects* serverObjects;
@property(weak) IBOutlet Updater* updater;

// for IONotification
@property IONotificationPortRef notifyport;
@property CFRunLoopSourceRef loopsource;

@property SessionObserver* sessionObserver;
@property PreferencesWindowController* preferencesWindowController;

@end

@implementation AppDelegate

@synthesize clientForKernelspace;

// ------------------------------------------------------------
static void observer_IONotification(void* refcon, io_iterator_t iterator) {
  dispatch_async(dispatch_get_main_queue(), ^{
    NSLog(@"observer_IONotification");

    AppDelegate* self = (__bridge AppDelegate*)(refcon);
    if (!self) {
      NSLog(@"[ERROR] observer_IONotification refcon == nil\n");
      return;
    }

    for (;;) {
      io_object_t obj = IOIteratorNext(iterator);
      if (!obj) break;

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
    [[self clientForKernelspace] refresh_connection_with_retry];
    [[self clientForKernelspace] send_config_to_kext];
  });
}

- (void)unregisterIONotification {
  if (self.notifyport) {
    if (self.loopsource) {
      CFRunLoopSourceInvalidate(self.loopsource);
      self.loopsource = nil;
    }
    IONotificationPortDestroy(self.notifyport);
    self.notifyport = nil;
  }
}

- (void)registerIONotification {
  [self unregisterIONotification];

  self.notifyport = IONotificationPortCreate(kIOMasterPortDefault);
  if (!self.notifyport) {
    NSLog(@"[ERROR] IONotificationPortCreate failed\n");
    return;
  }

  // ----------------------------------------------------------------------
  io_iterator_t it;
  kern_return_t kernResult;

  kernResult = IOServiceAddMatchingNotification(self.notifyport,
                                                kIOMatchedNotification,
                                                IOServiceNameMatching("org_pqrs_driver_Seil"),
                                                &observer_IONotification,
                                                (__bridge void*)(self),
                                                &it);
  if (kernResult != kIOReturnSuccess) {
    NSLog(@"[ERROR] IOServiceAddMatchingNotification failed");
    return;
  }
  observer_IONotification((__bridge void*)(self), it);

  // ----------------------------------------------------------------------
  self.loopsource = IONotificationPortGetRunLoopSource(self.notifyport);
  if (!self.loopsource) {
    NSLog(@"[ERROR] IONotificationPortGetRunLoopSource failed");
    return;
  }
  CFRunLoopAddSource(CFRunLoopGetCurrent(), self.loopsource, kCFRunLoopDefaultMode);
}

// ------------------------------------------------------------
- (void)observer_NSWindowWillCloseNotification:(NSNotification*)notification {
  dispatch_async(dispatch_get_main_queue(), ^{
    NSWindow* window = [notification object];
    if (self.preferencesWindowController &&
        self.preferencesWindowController.window == window) {
      self.preferencesWindowController = nil;
    }
  });
}

// ------------------------------------------------------------
- (void)applicationDidFinishLaunching:(NSNotification*)aNotification {
  NSInteger relaunchedCount = [Relauncher getRelaunchedCount];

  // ------------------------------------------------------------
  if ([MigrationUtilities migrate:@[ @"org.pqrs.PCKeyboardHack" ]
           oldApplicationSupports:@[]
                         oldPaths:@[ @"/Applications/PCKeyboardHack.app" ]]) {
    [Relauncher relaunch];
  }

  // ------------------------------------------------------------
  if (![self.serverForUserspace register]) {
    // Relaunch when register is failed.
    NSLog(@"[ServerForUserspace register] is failed. Restarting process.");
    [NSThread sleepForTimeInterval:2];
    [Relauncher relaunch];
  }
  [Relauncher resetRelaunchedCount];

  [[NSApplication sharedApplication] disableRelaunchOnLogin];

  self.sessionObserver = [[SessionObserver alloc] init:1
      active:^{
        [self registerIONotification];
      }
      inactive:^{
        [self unregisterIONotification];
        [clientForKernelspace disconnect_from_kext];
      }];

  // ------------------------------------------------------------
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(observer_NSWindowWillCloseNotification:)
                                               name:NSWindowWillCloseNotification
                                             object:nil];

  // ------------------------------------------------------------
  if (relaunchedCount == 0) {
    [self.updater checkForUpdatesInBackground];
  } else {
    NSLog(@"Skip checkForUpdatesInBackground in the relaunched process.");
  }

  // ------------------------------------------------------------
  // Open Preferences if Seil was launched by hand.
  {
    NSString* bundlePath = [[NSBundle mainBundle] bundlePath];
    if (![bundlePath isEqualToString:@"/Applications/Seil.app"]) {
      NSLog(@"Skip setStartAtLogin for %@", bundlePath);

      if (relaunchedCount == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
          NSAlert* alert = [NSAlert new];
          [alert setMessageText:@"Seil Alert"];
          [alert addButtonWithTitle:@"Close"];
          [alert setInformativeText:@"Seil.app should be located in /Applications/Seil.app.\nDo not move Seil.app into other folders."];
          [alert runModal];
        });
      }

    } else {
      if (![StartAtLoginUtilities isStartAtLogin] &&
          [[NSUserDefaults standardUserDefaults] boolForKey:kResumeAtLogin]) {
        if (relaunchedCount == 0) {
          [self openPreferences];
        }
      }
      [ServerController updateStartAtLogin:YES];
    }
  }
}

- (BOOL)applicationShouldHandleReopen:(NSApplication*)theApplication hasVisibleWindows:(BOOL)flag {
  [self openPreferences];
  return YES;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)openPreferences {
  if (self.preferencesWindowController == nil) {
    self.preferencesWindowController = [[PreferencesWindowController alloc] initWithServerObjects:@"PreferencesWindow" serverObjects:self.serverObjects];
  }
  [self.preferencesWindowController show];
}

@end
