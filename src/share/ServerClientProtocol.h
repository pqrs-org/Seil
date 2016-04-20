// -*- Mode: objc; Coding: utf-8; indent-tabs-mode: nil; -*-

@import Cocoa;

@class PreferencesModel;
@class MainConfigurationTree;

@protocol ServerClientProtocol

- (NSString*)bundleVersion;

- (void)loadPreferencesModel:(PreferencesModel*)preferencesModel;
- (void)savePreferencesModel:(PreferencesModel*)preferencesModel processIdentifier:(int)processIdentifier;
- (NSDictionary*)exportPreferences;
- (void)updateStartAtLogin;

- (bycopy MainConfigurationTree*)mainConfigurationTree;
- (bycopy NSArray*)knownKeyCodes;

- (void)terminateServerProcess;
- (void)relaunch;

- (void)checkForUpdatesStableOnly;
- (void)checkForUpdatesWithBetaVersion;

@end
