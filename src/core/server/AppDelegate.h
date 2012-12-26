// -*- Mode: objc -*-

#import <Cocoa/Cocoa.h>
#import "Sparkle/SUUpdater.h"

@class OutlineView_mixed;
@class PreferencesController;
@class Updater;

@interface AppDelegate : NSObject <NSApplicationDelegate> {
  NSWindow* window;

  // for IONotification
  IONotificationPortRef notifyport_;
  CFRunLoopSourceRef loopsource_;

  IBOutlet OutlineView_mixed* outlineView_mixed_;
  IBOutlet PreferencesController* preferencesController_;
  IBOutlet Updater* updater_;
}

@property (assign) IBOutlet NSWindow* window;

- (IBAction) launchUninstaller:(id)sender;

@end
