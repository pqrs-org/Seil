// -*- Mode: objc; Coding: utf-8; indent-tabs-mode: nil; -*-

@import Cocoa;
#import "SeilProtocol.h"

@interface SeilClient : NSObject

- (NSDistantObject<SeilProtocol>*)proxy;

@end
