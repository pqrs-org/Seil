// -*- Mode: objc; Coding: utf-8; indent-tabs-mode: nil; -*-

#import <Cocoa/Cocoa.h>

@interface PreferencesManager : NSObject

- (int)value:(NSString *)name;
- (int)defaultValue:(NSString *)name;
- (void)setValue:(int)newval forName:(NSString*)name;
- (void)setValue:(int)newval forName:(NSString*)name notificationUserInfo:(NSDictionary*)notificationUserInfo;

- (BOOL)isCheckForUpdates;

@end
