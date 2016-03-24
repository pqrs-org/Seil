// -*- Mode: objc; Coding: utf-8; indent-tabs-mode: nil; -*-

@import Cocoa;

@protocol ServerClientProtocol

- (void)setValue:(int)newval forName:(NSString *)name;
- (NSDictionary *)allValues;
- (void)relaunch;

@end
