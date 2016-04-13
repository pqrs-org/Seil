#import "SharedUtilities.h"

@implementation SharedUtilities

+ (BOOL)confirmQuit {
  NSAlert* alert = [NSAlert new];
  alert.messageText = @"Are you sure you want to quit Seil?";
  alert.informativeText = @"The changed key will be restored after Seil is quit.";
  [alert addButtonWithTitle:@"Quit"];
  [alert addButtonWithTitle:@"Cancel"];
  return [alert runModal] == NSAlertFirstButtonReturn;
}

@end
