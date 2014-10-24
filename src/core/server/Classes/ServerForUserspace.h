// -*- Mode: objc; Coding: utf-8; indent-tabs-mode: nil; -*-

#import <Cocoa/Cocoa.h>
#import "SeilProtocol.h"

@class PreferencesManager;

@interface ServerForUserspace : NSObject <SeilProtocol> {
  IBOutlet PreferencesManager* preferencesManager_;
}

- (BOOL) register;

@end
