// -*- Mode: objc -*-

@import Cocoa;

@interface KnownKeyCode : NSObject

@property(copy, readonly) NSString* name;
@property(readonly) int keyCode;

- (instancetype)initWithName:(NSString*)name keyCode:(int)keyCode;

@end
