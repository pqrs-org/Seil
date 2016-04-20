#import "PreferencesWindowController.h"
#import "KnownTableViewDataSource.h"
#import "MainOutlineView.h"
#import "MainOutlineViewDataSource.h"
#import "PreferencesModel.h"
#import "Relauncher.h"
#import "ServerClient.h"
#import "SharedKeys.h"
#import "SharedUtilities.h"

@interface PreferencesWindowController ()

@property(weak) IBOutlet KnownTableViewDataSource* knownTableViewDataSource;
@property(weak) IBOutlet MainOutlineView* mainOutlineView;
@property(weak) IBOutlet MainOutlineViewDataSource* mainOutlineViewDataSource;
@property(weak) IBOutlet NSTableView* knownTableView;
@property(weak) IBOutlet NSTextField* versionText;
@property(weak) IBOutlet PreferencesModel* preferencesModel;
@property(weak) IBOutlet ServerClient* client;

@end

@implementation PreferencesWindowController

- (void)observer_kSeilServerDidLaunchNotification:(NSNotification*)notification {
  dispatch_async(dispatch_get_main_queue(), ^{
    [Relauncher relaunch];
  });
}

- (void)observer_kSeilPreferencesUpdatedNotification:(NSNotification*)notification {
  dispatch_async(dispatch_get_main_queue(), ^{
    if (notification.userInfo &&
        [notification.userInfo[@"processIdentifier"] intValue] != [NSProcessInfo processInfo].processIdentifier) {
      NSLog(@"PreferencesModel is changed in another process.");
      [self.client.proxy loadPreferencesModel:self.preferencesModel];
      [self.mainOutlineView reloadData];
    }
  });
}

- (void)setup {
  [Relauncher resetRelaunchedCount];

  [self checkServerClient];

  // In Mac OS X 10.7, NSDistributedNotificationCenter is suspended after calling [NSAlert runModal].
  // So, we need to set suspendedDeliveryBehavior to NSNotificationSuspensionBehaviorDeliverImmediately.
  [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                      selector:@selector(observer_kSeilServerDidLaunchNotification:)
                                                          name:kSeilServerDidLaunchNotification
                                                        object:nil
                                            suspensionBehavior:NSNotificationSuspensionBehaviorDeliverImmediately];

  [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                      selector:@selector(observer_kSeilPreferencesUpdatedNotification:)
                                                          name:kSeilPreferencesUpdatedNotification
                                                        object:nil
                                            suspensionBehavior:NSNotificationSuspensionBehaviorDeliverImmediately];

  NSString* version = [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
  [self.versionText setStringValue:version];

  [self.mainOutlineViewDataSource setup];
  [self.knownTableViewDataSource setup];

  [self.mainOutlineView reloadData];
  [self.knownTableView reloadData];
}

- (void)dealloc {
  [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
}

- (void)windowDidBecomeMain:(NSNotification*)notification {
  [self checkServerClient];
}

- (void)show {
  [self.window makeKeyAndOrderFront:self];
  [NSApp activateIgnoringOtherApps:YES];
}

- (void)checkServerClient {
  if ([[self.client.proxy bundleVersion] length] == 0) {
    NSLog(@"Seil server is not running.");
    [NSApp terminate:self];
  }
}

- (void)savePreferencesModel {
  [self.client.proxy savePreferencesModel:self.preferencesModel processIdentifier:[NSProcessInfo processInfo].processIdentifier];
}

- (IBAction)quitWithConfirmation:(id)sender {
  if ([SharedUtilities confirmQuit]) {
    @try {
      [self.client.proxy terminateServerProcess];
    } @catch (NSException* exception) {
    }

    [NSApp terminate:nil];
  }
}

- (IBAction)checkForUpdatesStableOnly:(id)sender {
  [self.client.proxy checkForUpdatesStableOnly];
}

- (IBAction)checkForUpdatesWithBetaVersion:(id)sender {
  [self.client.proxy checkForUpdatesWithBetaVersion];
}

- (IBAction)preferencesChanged:(id)sender {
  [self savePreferencesModel];
}

- (IBAction)resumeAtLoginChanged:(id)sender {
  [self savePreferencesModel];
  [self.client.proxy updateStartAtLogin];
}

- (IBAction)launchUninstaller:(id)sender {
  NSString* path = @"/Library/Application Support/org.pqrs/Seil/uninstaller.applescript";
  [[[NSAppleScript alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:nil] executeAndReturnError:nil];
}

- (IBAction)openURL:(id)sender {
  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[sender title]]];
}

@end
