// -*- Mode: objc; Coding: utf-8; indent-tabs-mode: nil; -*-

#import <PreferencePanes/PreferencePanes.h>
#import "PCKeyboardHackClient.h"

@interface PCKeyboardHackPref : NSPreferencePane
{
  IBOutlet id _versionText;
  IBOutlet id _outlineView_mixed;
  IBOutlet org_pqrs_PCKeyboardHack_Client* client_;
}

- (IBAction) launchUninstaller:(id)sender;
- (void) mainViewDidLoad;

@end
