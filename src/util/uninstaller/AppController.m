#import "AppController.h"
#import "AdminAction.h"

@implementation AppController

static NSString* appName = @"PCKeyboardHack";
static char uninstallCommand[] = "/Library/org.pqrs/PCKeyboardHack/extra/uninstall.sh";

- (void) setMessage
{
  [_message setStringValue:[NSString stringWithFormat:@"%@ Uninstaller", appName]];
}

// ----------------------------------------------------------------------
- (IBAction) uninstall:(id)sender
{
  BOOL result = [AdminAction execCommand:uninstallCommand];
  if (result) {
    NSRunAlertPanel(@"Uninstaller", [NSString stringWithFormat:@"%@ is uninstalled.", appName], @"OK", nil, nil);
  } else {
    NSRunAlertPanel(@"Uninstaller", [NSString stringWithFormat:@"Failed to uninstall %@.", appName], @"OK", nil, nil);
  }
  [NSApp terminate:self];
}

// ----------------------------------------------------------------------
- (void) applicationDidFinishLaunching:(NSNotification*)notification
{
  [self setMessage];
}

@end
