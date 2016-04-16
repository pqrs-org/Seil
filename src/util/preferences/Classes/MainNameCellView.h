// -*- Mode: objc -*-

@import Cocoa;

@class MainNameBackgroundView;
@class PreferencesModel;
@class PreferencesWindowController;

@interface MainNameCellView : NSTableCellView

@property(weak) IBOutlet NSLayoutConstraint* labelLeadingSpace;
@property MainNameBackgroundView* backgroundView;
@property NSButton* checkbox;
@property(copy) NSString* settingIdentifier;
@property(weak) PreferencesModel* preferencesModel;
@property(weak) PreferencesWindowController* preferencesWindowController;

- (void)addLayoutConstraint:(NSView*)subview top:(CGFloat)top bottom:(CGFloat)bottom leading:(CGFloat)leading trailing:(CGFloat)trailing;
- (void)toggle;
- (void)valueChanged:(id)sender;

@end
