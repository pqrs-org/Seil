// -*- Mode: objc -*-

@import Cocoa;

@class MainNameBackgroundView;
@class ServerObjects;

@interface MainNameCellView : NSTableCellView

@property(weak) IBOutlet NSLayoutConstraint* labelLeadingSpace;
@property(weak) IBOutlet NSLayoutConstraint* labelTopSpace;
@property(weak) IBOutlet NSLayoutConstraint* labelBottomSpace;
@property(weak) ServerObjects* serverObjects;
@property MainNameBackgroundView* backgroundView;
@property NSButton* checkbox;
@property(copy) NSString* settingIdentifier;

- (void)addLayoutConstraint:(NSView*)subview top:(CGFloat)top bottom:(CGFloat)bottom leading:(CGFloat)leading trailing:(CGFloat)trailing;
- (void)toggle;
- (void)valueChanged:(id)sender;

@end
