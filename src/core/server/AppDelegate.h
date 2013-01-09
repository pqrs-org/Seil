// -*- Mode: objc -*-

#import <Cocoa/Cocoa.h>

@class ClientForKernelspace;
@class OutlineView_mixed;
@class PreferencesController;
@class Updater;

@interface AppDelegate : NSObject <NSApplicationDelegate> {
  NSWindow* window;

  // for IONotification
  IONotificationPortRef notifyport_;
  CFRunLoopSourceRef loopsource_;

  IBOutlet ClientForKernelspace* clientForKernelspace;
  IBOutlet OutlineView_mixed* outlineView_mixed_;
  IBOutlet PreferencesController* preferencesController_;
  IBOutlet Updater* updater_;
}

@property (assign) IBOutlet NSWindow* window;
@property (assign) ClientForKernelspace* clientForKernelspace;

- (IBAction) launchUninstaller:(id)sender;

@end
