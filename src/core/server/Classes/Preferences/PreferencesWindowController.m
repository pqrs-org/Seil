#import "AppDelegate.h"
#import "PreferencesWindowController.h"
#import "Updater.h"
#import "ServerObjects.h"

@interface PreferencesWindowController ()

@property(weak) IBOutlet ServerObjects* serverObjects;

@end

@implementation PreferencesWindowController

- (IBAction)quit:(id)sender {
  [AppDelegate quitWithConfirmation];
}

- (IBAction)checkForUpdatesStableOnly:(id)sender {
  [self.serverObjects.updater checkForUpdatesStableOnly];
}

- (IBAction)checkForUpdatesWithBetaVersion:(id)sender {
  [self.serverObjects.updater checkForUpdatesWithBetaVersion];
}

- (IBAction)launchUninstaller:(id)sender {
  NSString* path = @"/Library/Application Support/org.pqrs/Seil/uninstaller.applescript";
  [[[NSAppleScript alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:nil] executeAndReturnError:nil];
}

@end
