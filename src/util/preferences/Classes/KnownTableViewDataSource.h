// -*- Mode: objc -*-

@import Cocoa;

@interface KnownTableViewDataSource : NSObject <NSTableViewDataSource>

@property(copy, readonly) NSArray* source;

- (void)setup;
- (NSString*)getKeyName:(int)keycode;

@end
