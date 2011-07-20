//
//  PCKeyboardHack_serverAppDelegate.h
//  PCKeyboardHack_server
//
//  Created by Takayama Fumihiko on 09/11/28.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PCKeyboardHack_serverAppDelegate : NSObject <NSApplicationDelegate> {
  NSWindow* window;

  // for IONotification
  IONotificationPortRef notifyport_;
  CFRunLoopSourceRef loopsource_;
}

@property (assign) IBOutlet NSWindow* window;

@end
