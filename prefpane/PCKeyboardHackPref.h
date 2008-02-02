// -*- Mode: objc; Coding: utf-8; indent-tabs-mode: nil; -*-

#import <PreferencePanes/PreferencePanes.h>
#import "SysctlWrapper.h"
#import "AdminAction.h"

@interface PCKeyboardHackPref : NSPreferencePane
{
  NSXMLDocument *_XMLDocument;
  SysctlWrapper *_sysctlWrapper;
  AdminAction *_adminAction;

  IBOutlet id _outlineView;
  IBOutlet id _versionText;
}

- (void) mainViewDidLoad;

@end
