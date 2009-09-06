// -*- Mode: objc; Coding: utf-8; indent-tabs-mode: nil; -*-

#import "PCKeyboardHackPref.h"
#import "Common.h"
#import "SysctlWrapper.h"

@implementation PCKeyboardHackPref

static NSString *launchUninstallerCommand = @"/Library/org.pqrs/PCKeyboardHack/extra/launchUninstaller.sh";

- (void) drawVersion
{
  NSString *version = [BUNDLEPREFIX(SysctlWrapper) getString:@"pckeyboardhack.version"];
  if (! version) {
    version = @"-.-.-";
  }
  [_versionText setStringValue:version];
}

// ----------------------------------------------------------------------
- (IBAction) launchUninstaller:(id)sender
{
  [BUNDLEPREFIX(Common) getExecResult:launchUninstallerCommand args:[NSArray arrayWithObjects:@"force", nil]];
}

// ----------------------------------------------------------------------
- (void) mainViewDidLoad
{
  [self drawVersion];
}

@end
