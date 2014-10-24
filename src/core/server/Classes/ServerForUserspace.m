#import "SeilKeys.h"
#import "PreferencesManager.h"
#import "Relauncher.h"
#import "ServerForUserspace.h"

@interface ServerForUserspace () {
  NSConnection* connection_;
}
@end

@implementation ServerForUserspace

- (id)init {
  self = [super init];

  if (self) {
    connection_ = [NSConnection new];
  }

  return self;
}

// ----------------------------------------------------------------------
- (BOOL) register {
  [connection_ setRootObject:self];
  if (![connection_ registerName:kSeilConnectionName]) {
    return NO;
  }
  return YES;
}

// ----------------------------------------------------------------------
- (void)setValue:(int)newval forName:(NSString*)name {
  [preferencesManager_ setValueForName:newval forName:name];
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
