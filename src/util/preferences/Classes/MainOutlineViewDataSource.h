// -*- Mode: objc -*-

@import Cocoa;

@class MainConfigurationTree;

@interface MainOutlineViewDataSource : NSObject <NSOutlineViewDataSource>

@property(copy, readonly) MainConfigurationTree* source;

- (void)setup;

@end
