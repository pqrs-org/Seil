// -*- Mode: objc; Coding: utf-8; indent-tabs-mode: nil; -*-

@import Cocoa;

@class PreferencesModel;

@interface PreferencesManager : NSObject

- (void)loadPreferencesModel:(PreferencesModel*)preferencesModel;
- (void)savePreferencesModel:(PreferencesModel*)preferencesModel processIdentifier:(int)processIdentifier;

- (int)value:(NSString*)name;
- (int)defaultValue:(NSString*)name;
- (void)setValue:(int)newval forName:(NSString*)name;
- (void)setValue:(int)newval forName:(NSString*)name notificationUserInfo:(NSDictionary*)notificationUserInfo;

- (BOOL)isCheckForUpdates;

@end
