#import "AppController.h"

@implementation AppController

NSTask *task_sysctl_confd = nil;

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification
{
  NSLog(@"PCKeyboardHack_launchd initialize");

  NSArray *args = [NSArray array];

  NSString *sysctl_confd = @"/Library/org.pqrs/PCKeyboardHack/bin/PCKeyboardHack_sysctl_confd";
  task_sysctl_confd = [NSTask launchedTaskWithLaunchPath:sysctl_confd arguments:args];
}

- (void) applicationWillTerminate:(NSNotification *)aNotification
{
  NSLog(@"PCKeyboardHack_launchd terminate");

  if (task_sysctl_confd) {
    [task_sysctl_confd terminate];
  }
}

@end
