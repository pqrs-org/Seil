// -*- Mode: objc -*-

@import Cocoa;

@class ServerObjects;

@interface MainValueCellView : NSTableCellView

@property(weak) ServerObjects* serverObjects;
@property(copy) NSString* settingIdentifier;

@end
