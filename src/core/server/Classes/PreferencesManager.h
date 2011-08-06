// -*- Mode: objc; Coding: utf-8; indent-tabs-mode: nil; -*-
#import <Cocoa/Cocoa.h>

@interface PreferencesManager : NSObject {
  NSMutableDictionary* default_;
  NSConnection* serverconnection_;
}

+ (PreferencesManager*) getInstance;

- (int) value:(NSString*)name;
- (int) defaultValue:(NSString*)name;
- (void) setValueForName:(int)newval forName:(NSString*)name;

- (NSInteger) checkForUpdatesMode;
- (void) setCheckForUpdatesMode:(NSInteger)newval;

// --------------------------------------------------
- (NSString*) preferencepane_version;

@end
