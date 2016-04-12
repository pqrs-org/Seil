// -*- Mode: objc -*-

@import Cocoa;

@class ServerObjects;
@class PreferencesWindowController;

@interface MainValueCellView : NSTableCellView

@property(copy) NSString* settingIdentifier;
@property(weak) PreferencesWindowController* preferencesWindowController;
@property(weak) ServerObjects* serverObjects;

@end
