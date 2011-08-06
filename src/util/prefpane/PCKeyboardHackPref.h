// -*- Mode: objc; Coding: utf-8; indent-tabs-mode: nil; -*-

#import <PreferencePanes/PreferencePanes.h>
#import "PCKeyboardHackClient.h"
#import "OutlineView_mixed.h"

@interface PCKeyboardHackPref : NSPreferencePane
{
  IBOutlet NSTextField* versionText_;
  IBOutlet NSPopUpButton* popup_checkupdate_;
  IBOutlet org_pqrs_PCKeyboardHack_OutlineView_mixed* outlineView_mixed_;
  IBOutlet org_pqrs_PCKeyboardHack_Client* client_;
}

- (IBAction) changeCheckUpdate:(id)sender;
- (IBAction) checkUpdateNow:(id)sender;
- (IBAction) launchUninstaller:(id)sender;
- (void) mainViewDidLoad;

@end
