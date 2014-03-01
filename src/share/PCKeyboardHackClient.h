// -*- Mode: objc; Coding: utf-8; indent-tabs-mode: nil; -*-

#import <Cocoa/Cocoa.h>
#import "PCKeyboardHackProtocol.h"

@interface PCKeyboardHackClient : NSObject {
  id proxy_;
}

- (id<PCKeyboardHackProtocol>) proxy;

@end
