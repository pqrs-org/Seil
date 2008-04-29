// -*- Mode: objc; Coding: utf-8; indent-tabs-mode: nil; -*-

#import "PCKeyboardHackPref.h"
#import "SysctlWrapper.h"

@implementation PCKeyboardHackPref

- (void) drawVersion
{
  NSString *version = [SysctlWrapper getString:@"pckeyboardhack.version"];
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
