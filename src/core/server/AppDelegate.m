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

@interface AppDelegate () {
  // for IONotification
  IONotificationPortRef notifyport_;
  CFRunLoopSourceRef loopsource_;

  SessionObserver* sessionObserver_;

  IBOutlet ServerForUserspace* serverForUserspace_;
}

@property(weak) IBOutlet ClientForKernelspace* clientForKernelspace;
@property(weak) IBOutlet ServerObjects* serverObjects;
@property(weak) IBOutlet Updater* updater;

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
  if (notifyport_) {
    if (loopsource_) {
      CFRunLoopSourceInvalidate(loopsource_);
      loopsource_ = nil;
    }
    IONotificationPortDestroy(notifyport_);
    notifyport_ = nil;
  }
}

- (void)registerIONotification {
  [self unregisterIONotification];

  notifyport_ = IONotificationPortCreate(kIOMasterPortDefault);
  if (!notifyport_) {
    NSLog(@"[ERROR] IONotificationPortCreate failed\n");
    return;
  }

  // ----------------------------------------------------------------------
  io_iterator_t it;
  kern_return_t kernResult;

  kernResult = IOServiceAddMatchingNotification(notifyport_,
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
  loopsource_ = IONotificationPortGetRunLoopSource(notifyport_);
  if (!loopsource_) {
    NSLog(@"[ERROR] IONotificationPortGetRunLoopSource failed");
    return;
  }
  CFRunLoopAddSource(CFRunLoopGetCurrent(), loopsource_, kCFRunLoopDefaultMode);
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
#define kDescendantProcess @"org_pqrs_Seil_DescendantProcess"

- (void)applicationDidFinishLaunching:(NSNotification*)aNotification {
  NSInteger isDescendantProcess = [[[NSProcessInfo processInfo] environment][kDescendantProcess] integerValue];
  setenv([kDescendantProcess UTF8String], "1", 1);

  if ([MigrationUtilities migrate:@[ @"org.pqrs.PCKeyboardHack" ]
           oldApplicationSupports:@[]
                         oldPaths:@[ @"/Applications/PCKeyboardHack.app" ]]) {
    [Relauncher relaunch];
  }

  // ------------------------------------------------------------
  if (![serverForUserspace_ register]) {
    // Relaunch when register is failed.
    NSLog(@"[ServerForUserspace register] is failed. Restarting process.");
    [NSThread sleepForTimeInterval:2];
    [Relauncher relaunch];
  }
  [Relauncher resetRelaunchedCount];

  [[NSApplication sharedApplication] disableRelaunchOnLogin];

  sessionObserver_ = [[SessionObserver alloc] init:1
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
  [self.updater checkForUpdatesInBackground];

  // ------------------------------------------------------------
  // Open Preferences if Seil was launched by hand.
  {
    NSString* bundlePath = [[NSBundle mainBundle] bundlePath];
    if (![bundlePath isEqualToString:@"/Applications/Seil.app"]) {
      NSLog(@"Skip setStartAtLogin for %@", bundlePath);

      dispatch_async(dispatch_get_main_queue(), ^{
        NSAlert* alert = [NSAlert new];
        [alert setMessageText:@"Seil Alert"];
        [alert addButtonWithTitle:@"Close"];
        [alert setInformativeText:@"Seil.app should be located in /Applications/Seil.app.\nDo not move Seil.app into other folders."];
        [alert runModal];
      });

    } else {
      if (![StartAtLoginUtilities isStartAtLogin] &&
          [[NSUserDefaults standardUserDefaults] boolForKey:kResumeAtLogin]) {
        if (!isDescendantProcess) {
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
