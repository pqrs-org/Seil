// -*- Mode: objc -*-

@import Cocoa;

@interface KnownTableViewDataSource : NSObject <NSTableViewDataSource>

@property(copy, readonly) NSArray* source;

- (NSString*)getKeyName:(int)keycode;

@end
