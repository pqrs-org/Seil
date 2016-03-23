#import "AppDelegate.h"
#import "MainOutlineView.h"
#import "PreferencesKeys.h"
#import "PreferencesWindowController.h"
#import "Relauncher.h"
#import "ServerController.h"
#import "ServerObjects.h"
#import "Updater.h"

@interface PreferencesWindowController ()

@property(weak) IBOutlet MainOutlineView* mainOutlineView;
@property(weak) IBOutlet NSTextField* versionText;

@end

@implementation PreferencesWindowController

- (instancetype)initWithServerObjects:(NSString*)windowNibName serverObjects:(ServerObjects*)serverObjects {
  self = [super initWithWindowNibName:windowNibName];

  if (self) {
    self.serverObjects = serverObjects;

    // Show icon in Dock only when Preferences has been opened.
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kShowIconInDock]) {
      ProcessSerialNumber psn = {0, kCurrentProcess};
      TransformProcessType(&psn, kProcessTransformToForegroundApplication);
    }
  }

  return self;
}

- (void)drawVersion {
  NSString* version = [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
  [self.versionText setStringValue:version];
}

- (void)windowDidBecomeMain:(NSNotification*)notification {
  [self drawVersion];
}

- (void)show {
  [self.window makeKeyAndOrderFront:self];
  [NSApp activateIgnoringOtherApps:YES];
}

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
