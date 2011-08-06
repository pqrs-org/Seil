// -*- Mode: objc; Coding: utf-8; indent-tabs-mode: nil; -*-
#import <Cocoa/Cocoa.h>

@protocol org_pqrs_PCKeyboardHack_Protocol
- (int) value:(NSString*)name;
- (int) defaultValue:(NSString*)name;
- (void) setValueForName:(int)newval forName:(NSString*)name;

- (NSInteger) checkForUpdatesMode;
- (void) setCheckForUpdatesMode:(NSInteger)newval;

- (NSString*) preferencepane_version;

@end

@interface org_pqrs_PCKeyboardHack_Client : NSObject {
  id proxy;
}

@property (assign) id proxy;

- (id) proxy;

@end
