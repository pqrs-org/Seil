#import "AppDelegate.h"
#import "PreferencesWindowController.h"
#import "Relauncher.h"
#import "ServerController.h"
#import "ServerObjects.h"
#import "Updater.h"

@interface PreferencesWindowController ()

@property(weak) IBOutlet ServerObjects* serverObjects;

@end

@implementation PreferencesWindowController

- (IBAction)quit:(id)sender {
  [ServerController quitWithConfirmation];
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

- (IBAction)openURL:(id)sender {
  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[sender title]]];
}

- (IBAction)updateStartAtLogin:(id)sender {
  [ServerController updateStartAtLogin:YES];
}

- (IBAction)relaunch:(id)sender {
  [Relauncher relaunch];
}

@end
