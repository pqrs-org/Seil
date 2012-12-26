#import <Cocoa/Cocoa.h>
#import "Sparkle/SUUpdater.h"

@interface AppDelegate : NSObject <NSApplicationDelegate> {
  NSWindow* window;
  IBOutlet SUUpdater* suupdater_;

  // for IONotification
  IONotificationPortRef notifyport_;
  CFRunLoopSourceRef loopsource_;
}

@property (assign) IBOutlet NSWindow* window;

@end
