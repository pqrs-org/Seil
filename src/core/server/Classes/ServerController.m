#import "ServerController.h"
#import "PreferencesModel.h"
#import "StartAtLoginUtilities.h"

@interface ServerController ()

@property(weak) IBOutlet PreferencesModel* preferencesModel;

@end

@implementation ServerController

- (void)terminateServerProcess {
  [self updateStartAtLogin:NO];
  [NSApp terminate:nil];
}

- (void)updateStartAtLogin:(BOOL)preferredValue {
  if (!preferredValue) {
    [StartAtLoginUtilities setStartAtLogin:NO];

  } else {
    // Do not register to StartAtLogin if kResumeAtLogin is NO.
    if (!self.preferencesModel.resumeAtLogin) {
      [StartAtLoginUtilities setStartAtLogin:NO];
    } else {
      [StartAtLoginUtilities setStartAtLogin:YES];
    }
  }
}

@end
