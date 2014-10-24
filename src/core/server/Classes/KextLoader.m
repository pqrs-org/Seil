// -*- Mode: objc; Coding: utf-8; indent-tabs-mode: nil; -*-

#import "KextLoader.h"

@implementation KextLoader

+ (void)load {
  @synchronized(self) {
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
      NSLog(@"kextload");

      NSString* kextload = @"/Applications/Seil.app/Contents/Library/bin/kextload";
      if (! [[NSFileManager defaultManager] fileExistsAtPath:kextload]) {
        dispatch_async(dispatch_get_main_queue(), ^ {
            NSAlert* alert = [NSAlert new];
            [alert setMessageText:@"Seil Error"];
            [alert addButtonWithTitle:@"Close"];
            [alert setInformativeText:@"You need to place Seil.app in /Applications."];

            [alert runModal];
          });
        return;
      }

      system([[NSString stringWithFormat:@"%@ load", kextload] UTF8String]);
      [NSThread sleepForTimeInterval:0.5];
    });
  }
}

@end
