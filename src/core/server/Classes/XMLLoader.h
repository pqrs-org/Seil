// -*- Mode: objc -*-

@import Cocoa;

@class MainConfigurationTree;

@interface XMLLoader : NSObject

+ (MainConfigurationTree*)loadMainConfiguration:(NSString*)filePath;
+ (NSArray*)loadKnownKeyCode:(NSString*)filePath;

@end
