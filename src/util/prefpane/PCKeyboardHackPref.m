// -*- Mode: objc; Coding: utf-8; indent-tabs-mode: nil; -*-

#import "PCKeyboardHackPref.h"
#include <stdlib.h>

@implementation PCKeyboardHackPref

static NSString* launchUninstallerCommand = @"/Library/org.pqrs/PCKeyboardHack/extra/launchUninstaller.sh";

- (void) drawVersion
{
  NSString* version = [[client_ proxy] preferencepane_version];
  if (! version) {
    version = @"-.-.-";
  }
  [_versionText setStringValue:version];
}

// ----------------------------------------------------------------------
- (IBAction) launchUninstaller:(id)sender
{
  system([launchUninstallerCommand UTF8String]);
}

// ----------------------------------------------------------------------
- (void) mainViewDidLoad
{
  [self drawVersion];
  [_outlineView_mixed expandItem:nil expandChildren:YES];
}

@end
