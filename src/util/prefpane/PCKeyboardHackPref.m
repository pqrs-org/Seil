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

- (void) mainViewDidLoad
{
  [self drawVersion];
}

@end
