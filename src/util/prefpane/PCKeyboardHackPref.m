// -*- Mode: objc; Coding: utf-8; indent-tabs-mode: nil; -*-

#import "PCKeyboardHackPref.h"
#import "sharecode.h"

@implementation PCKeyboardHackPref

- (void) drawVersion
{
  NSString *version = [BUNDLEPREFIX_SysctlWrapper getString:@"pckeyboardhack.version"];
  if (! version) {
    version = @"-.-.-";
  }
  [_versionText setStringValue:version];
}

// ----------------------------------------------------------------------
- (void) registerLoginWindow
{
  NSString *app = @"/Library/org.pqrs/PCKeyboardHack/app/PCKeyboardHack_launchd.app";

  NSString *set_loginwindow = @"/Library/org.pqrs/PCKeyboardHack/bin/set_loginwindow";
  NSString *result = [BUNDLEPREFIX_Common getExecResult:set_loginwindow args:[NSArray arrayWithObjects:@"exist", app, nil]];
  if ([result intValue] == 0) {
    [[NSWorkspace sharedWorkspace] launchApplication:app];

    [BUNDLEPREFIX_Common getExecResult:set_loginwindow args:[NSArray arrayWithObjects:@"set", app, nil]];
  }
}

// ----------------------------------------------------------------------
- (void) mainViewDidLoad
{
  [self drawVersion];
  [self registerLoginWindow];
}

@end
