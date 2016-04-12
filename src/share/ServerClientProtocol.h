// -*- Mode: objc; Coding: utf-8; indent-tabs-mode: nil; -*-

@import Cocoa;

@class PreferencesModel;

@protocol ServerClientProtocol

- (void)loadPreferencesModel:(PreferencesModel*)preferencesModel;
- (void)savePreferencesModel:(PreferencesModel*)preferencesModel processIdentifier:(int)processIdentifier;
- (NSDictionary*)exportPreferences;

- (void)terminateServerProcess;
- (void)relaunch;

@end
