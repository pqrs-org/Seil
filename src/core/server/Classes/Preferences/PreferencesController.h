/* -*- Mode: objc; Coding: utf-8; indent-tabs-mode: nil; -*- */

@class PreferencesManager;

@interface PreferencesController : NSObject <NSWindowDelegate, NSTabViewDelegate>
{
  IBOutlet NSTextField* versionText_;
  IBOutlet NSWindow* preferencesWindow_;
  IBOutlet PreferencesManager* preferencesManager_;
}

- (void) show;

@end
