#import "PreferencesWindowController.h"
#import "Updater.h"
#import "ServerObjects.h"

@interface PreferencesWindowController ()

@property(weak) IBOutlet ServerObjects* serverObjects;

@end

@implementation PreferencesWindowController

- (IBAction)checkForUpdatesStableOnly:(id)sender {
  [self.serverObjects.updater checkForUpdatesStableOnly];
}

- (IBAction)checkForUpdatesWithBetaVersion:(id)sender {
  [self.serverObjects.updater checkForUpdatesWithBetaVersion];
}

@end
