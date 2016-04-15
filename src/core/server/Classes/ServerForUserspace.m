#import "ServerForUserspace.h"
#import "KnownKeyCode.h"
#import "MainConfigurationTree.h"
#import "PreferencesManager.h"
#import "Relauncher.h"
#import "ServerController.h"
#import "SharedKeys.h"
#import "Updater.h"
#import "XMLLoader.h"

@interface ServerForUserspace ()

@property(weak) IBOutlet PreferencesManager* preferencesManager;
@property(weak) IBOutlet ServerController* serverController;
@property(weak) IBOutlet Updater* updater;
@property NSConnection* connection;
@property(readwrite) MainConfigurationTree* mainConfigurationTree;
@property(copy, readwrite) NSArray* knownKeyCodes;

@end

@implementation ServerForUserspace

- (instancetype)init {
  self = [super init];

  if (self) {
    self.connection = [NSConnection new];
  }

  return self;
}

- (BOOL)registerService {
  [self.connection setRootObject:self];
  if (![self.connection registerName:kSeilConnectionName]) {
    return NO;
  }
  return YES;
}

- (void)setup {
  self.mainConfigurationTree = [XMLLoader loadMainConfiguration:[[NSBundle mainBundle] pathForResource:@"checkbox" ofType:@"xml"]];
  self.knownKeyCodes = [XMLLoader loadKnownKeyCode:[[NSBundle mainBundle] pathForResource:@"known" ofType:@"xml"]];
}

// ----------------------------------------------------------------------
- (NSString*)bundleVersion {
  return [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
}

- (void)loadPreferencesModel:(PreferencesModel*)preferencesModel {
  [self.preferencesManager loadPreferencesModel:preferencesModel];
}

- (void)savePreferencesModel:(PreferencesModel*)preferencesModel processIdentifier:(int)processIdentifier {
  [self.preferencesManager savePreferencesModel:preferencesModel processIdentifier:processIdentifier];
}

- (NSDictionary*)exportPreferences {
  return [self.preferencesManager export];
}

- (void)updateStartAtLogin {
  [self.serverController updateStartAtLogin:YES];
}

- (void)terminateServerProcess {
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.serverController terminateServerProcess];
  });
}

- (void)relaunch {
  // Use dispatch_async in order to avoid "disconnected from server".
  //
  // Example error message of disconnection:
  //   "seil: connection went invalid while waiting for a reply because a mach port died"
  dispatch_async(dispatch_get_main_queue(), ^{
    [Relauncher relaunch];
  });
}

- (void)checkForUpdatesStableOnly {
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.updater checkForUpdatesStableOnly];
  });
}

- (void)checkForUpdatesWithBetaVersion {
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.updater checkForUpdatesWithBetaVersion];
  });
}

@end
