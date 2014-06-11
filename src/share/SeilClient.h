// -*- Mode: objc; Coding: utf-8; indent-tabs-mode: nil; -*-

#import <Cocoa/Cocoa.h>
#import "SeilProtocol.h"

@interface SeilClient : NSObject {
  id proxy_;
}

- (id<SeilProtocol>) proxy;

@end
