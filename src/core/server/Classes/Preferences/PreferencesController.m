/* -*- Mode: objc; Coding: utf-8; indent-tabs-mode: nil; -*- */

#import "NotificationKeys.h"
#import "PreferencesController.h"
#import "PreferencesManager.h"

@implementation PreferencesController

/* ---------------------------------------------------------------------- */
- (void) drawVersion
{
  NSString* version = [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
  [versionText_ setStringValue:version];
}

/* ---------------------------------------------------------------------- */
- (void) windowDidBecomeMain:(NSNotification*)notification
{
  [self drawVersion];
}

/* ---------------------------------------------------------------------- */
- (void) show
{
  [preferencesWindow_ makeKeyAndOrderFront:self];
  [NSApp activateIgnoringOtherApps:YES];
}

@end
