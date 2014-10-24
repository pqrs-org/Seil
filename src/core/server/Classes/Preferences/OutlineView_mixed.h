// -*- Mode: objc; Coding: utf-8; indent-tabs-mode: nil; -*-

#import <Cocoa/Cocoa.h>
#import "OutlineView.h"

@class OutlineView_keycode;
@class PreferencesManager;

@interface OutlineView_mixed : OutlineView {
  IBOutlet NSOutlineView* outlineview_;
  IBOutlet OutlineView_keycode* outlineView_keycode_;
  IBOutlet PreferencesManager* preferencesManager_;
}

- (void)initialExpandCollapseTree;

@end
