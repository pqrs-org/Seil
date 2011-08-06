// -*- Mode: objc; Coding: utf-8; indent-tabs-mode: nil; -*-

#import "PCKeyboardHackPref.h"
#import "PCKeyboardHackKeys.h"
#import "PCKeyboardHackNSDistributedNotificationCenter.h"
#include <stdlib.h>

@implementation PCKeyboardHackPref

static NSString* launchUninstallerCommand = @"/Library/org.pqrs/PCKeyboardHack/extra/launchUninstaller.sh";

- (void) drawVersion
{
  NSString* version = [[client_ proxy] preferencepane_version];
  if (! version) {
    version = @"-.-.-";
  }
  [versionText_ setStringValue:version];
}

// ----------------------------------------------------------------------
- (void) setCheckUpdateState
{
  [popup_checkupdate_ selectItemAtIndex:[[client_ proxy] checkForUpdatesMode]];
}

- (IBAction) changeCheckUpdate:(id)sender
{
  [[client_ proxy] setCheckForUpdatesMode:[popup_checkupdate_ indexOfSelectedItem]];
  [self setCheckUpdateState];
}

- (IBAction) checkUpdateNow:(id)sender
{
  [org_pqrs_PCKeyboardHack_NSDistributedNotificationCenter postNotificationName:kPCKeyboardHackCheckForUpdatesNotification userInfo:nil];
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
  [outlineView_mixed_ initialExpandCollapseTree];

  // For some reason, launchd does not start PCKeyboardHack server process permanently.
  // (And we can recover it by reloading plist.)
  //
  // However, calling launchctl in Terminal.app is not familiar for everyone.
  // Therefore, we call launchctl at prefpane.
  system("/bin/launchctl load -w /Library/LaunchAgents/org.pqrs.PCKeyboardHack.server.plist 2> /dev/null");
}

@end
