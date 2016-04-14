// -*- Mode: objc -*-

@import Cocoa;

@interface MainConfigurationItem : NSObject

@property(readonly) NSNumber* id;
@property(copy, readonly) NSString* name;
@property(copy, readonly) NSString* style;
@property(copy, readonly) NSString* enableKey;
@property(copy, readonly) NSString* keyCodeKey;
@property(readonly) int defaultKeyCode;

- (instancetype)initWithName:(NSString*)name
                       style:(NSString*)style
                   enableKey:(NSString*)enableKey
                  keyCodeKey:(NSString*)keyCodeKey
              defaultKeyCode:(int)defaultKeyCode;

@end

@interface MainConfigurationTree : NSObject

@property(readonly) MainConfigurationItem* node;
@property(copy, readonly) NSArray* children;

- (instancetype)initWithItem:(MainConfigurationItem*)node
                    children:(NSArray*)children;

@end
