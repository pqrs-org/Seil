// -*- Mode: objc -*-

#import <Cocoa/Cocoa.h>

@class ClientForKernelspace;
@class OutlineView_mixed;
@class PreferencesController;
@class Updater;

@interface AppDelegate : NSObject <NSApplicationDelegate> {
  NSWindow* __weak window;

  // for IONotification
  IONotificationPortRef notifyport_;
  CFRunLoopSourceRef loopsource_;

  IBOutlet ClientForKernelspace* __weak clientForKernelspace;
  IBOutlet OutlineView_mixed* outlineView_mixed_;
  IBOutlet PreferencesController* preferencesController_;
  IBOutlet Updater* updater_;
}

@property (weak) IBOutlet NSWindow* window;
@property (weak) ClientForKernelspace* clientForKernelspace;

- (IBAction) launchUninstaller:(id)sender;

@end
