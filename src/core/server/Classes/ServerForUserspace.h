// -*- Mode: objc; Coding: utf-8; indent-tabs-mode: nil; -*-

#import <Cocoa/Cocoa.h>
#import "PCKeyboardHackProtocol.h"

@class PreferencesManager;

@interface ServerForUserspace : NSObject<PCKeyboardHackProtocol>
{
  IBOutlet PreferencesManager* preferencesManager_;
}

- (BOOL) register;

@end
