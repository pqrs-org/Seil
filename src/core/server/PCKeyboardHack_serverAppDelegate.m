//
//  PCKeyboardHack_serverAppDelegate.m
//  PCKeyboardHack_server
//
//  Created by Takayama Fumihiko on 09/11/28.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PCKeyboardHack_serverAppDelegate.h"
#include "util.h"

@implementation PCKeyboardHack_serverAppDelegate

@synthesize window;

- (void) configThreadMain {
  for (;;) {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    {
      sysctl_load();
      sleep(1);
    }
    [pool drain];
  }

  [NSThread exit];
}

// ------------------------------------------------------------
- (void) observer_NSWorkspaceSessionDidBecomeActiveNotification:(NSNotification*)notification
{
  NSLog(@"observer_NSWorkspaceSessionDidBecomeActiveNotification");

  // Note: The console user is "real login user" or "loginwindow",
  //       when NSWorkspaceSessionDidBecomeActiveNotification, NSWorkspaceSessionDidResignActiveNotification are called.
  sysctl_reset();
  sysctl_load();
}

- (void) observer_NSWorkspaceSessionDidResignActiveNotification:(NSNotification*)notification
{
  NSLog(@"observer_NSWorkspaceSessionDidResignActiveNotification");

  // Note: The console user is "real login user" or "loginwindow",
  //       when NSWorkspaceSessionDidBecomeActiveNotification, NSWorkspaceSessionDidResignActiveNotification are called.
  sysctl_reset();
}

// ------------------------------------------------------------
- (void) applicationDidFinishLaunching:(NSNotification*)aNotification {
  [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
                                                         selector:@selector(observer_NSWorkspaceSessionDidBecomeActiveNotification:)
                                                             name:NSWorkspaceSessionDidBecomeActiveNotification
                                                           object:nil];

  [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
                                                         selector:@selector(observer_NSWorkspaceSessionDidResignActiveNotification:)
                                                             name:NSWorkspaceSessionDidResignActiveNotification
                                                           object:nil];

  // ------------------------------------------------------------
  sysctl_reset();
  [NSThread detachNewThreadSelector:@selector(configThreadMain)toTarget:self withObject:nil];
}

- (void) applicationWillTerminate:(NSNotification*)aNotification {
  NSLog(@"applicationWillTerminate");
  sysctl_reset();
}

@end
