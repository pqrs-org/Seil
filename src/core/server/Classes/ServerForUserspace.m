#import "PreferencesManager.h"
#import "Relauncher.h"
#import "ServerForUserspace.h"
#import "SharedKeys.h"

@interface ServerForUserspace ()

@property(weak) IBOutlet PreferencesManager* preferencesManager;
@property NSConnection* connection;

@end

@implementation ServerForUserspace

- (id)init {
  self = [super init];

  if (self) {
    self.connection = [NSConnection new];
  }

  return self;
}

// ----------------------------------------------------------------------
- (BOOL) register {
  [self.connection setRootObject:self];
  if (![self.connection registerName:kSeilConnectionName]) {
    return NO;
  }
  return YES;
}

// ----------------------------------------------------------------------
- (void)setValue:(int)newval forName:(NSString*)name {
  [self.preferencesManager setValue:newval forName:name];
}

- (NSDictionary*)allValues {
  return @{
#include "../../../bridge/output/configurationDictionary.m"
  };
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

@end
