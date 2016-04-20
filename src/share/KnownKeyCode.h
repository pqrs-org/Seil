// -*- Mode: objc -*-

@import Cocoa;

@interface KnownKeyCode : NSObject <NSCoding>

@property(copy, readonly) NSString* name;
@property(copy, readonly) NSString* keyCode;

- (instancetype)initWithName:(NSString*)name keyCode:(NSString*)keyCode;

@end
