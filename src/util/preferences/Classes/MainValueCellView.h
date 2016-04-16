// -*- Mode: objc -*-

@import Cocoa;

@class PreferencesModel;
@class PreferencesWindowController;

@interface MainValueCellView : NSTableCellView

@property(copy) NSString* settingIdentifier;
@property(weak) PreferencesModel* preferencesModel;
@property(weak) PreferencesWindowController* preferencesWindowController;

@end
