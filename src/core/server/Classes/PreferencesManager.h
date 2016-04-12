// -*- Mode: objc; Coding: utf-8; indent-tabs-mode: nil; -*-

@import Cocoa;

@class PreferencesModel;

@interface PreferencesManager : NSObject

- (void)loadPreferencesModel:(PreferencesModel*)preferencesModel;
- (void)savePreferencesModel:(PreferencesModel*)preferencesModel processIdentifier:(int)processIdentifier;
- (NSDictionary*)export;

@end
