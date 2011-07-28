// -*- Mode: objc; Coding: utf-8; indent-tabs-mode: nil; -*-
#import <Cocoa/Cocoa.h>
#import "PCKeyboardHackClient.h"
#import "OutlineView_keycode.h"

@interface org_pqrs_PCKeyboardHack_OutlineView_mixed : NSObject
{
  IBOutlet org_pqrs_PCKeyboardHack_Client* client_;
  IBOutlet org_pqrs_PCKeyboardHack_OutlineView_keycode* outlineview_keycode_;
}

@end
