#import "PCKeyboardHackClient.h"
#import "PCKeyboardHackKeys.h"

@implementation org_pqrs_PCKeyboardHack_Client

@synthesize proxy;

- (void) refresh_connection
{
  [proxy release];
  proxy = [[NSConnection rootProxyForConnectionWithRegisteredName:kPCKeyboardHackConnectionName host:nil] retain];
  [proxy setProtocolForProxy:@protocol(org_pqrs_PCKeyboardHack_Protocol)];
}

- (void) observer_NSConnectionDidDieNotification:(NSNotification*)notification
{
  [self refresh_connection];
}

- (void) observer_serverLaunched:(NSNotification*)notification
{
  NSLog(@"observer_serverLaunched called");
  [self refresh_connection];
}

- (id) init
{
  self = [super init];

  if (self) {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(observer_NSConnectionDidDieNotification:)
                                                 name:NSConnectionDidDieNotification
                                               object:nil];

    [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                        selector:@selector(observer_serverLaunched:)
                                                            name:kPCKeyboardHackServerLaunchedNotification
                                                          object:kPCKeyboardHackNotificationKey];

    [self refresh_connection];
  }

  return self;
}

- (void) dealloc
{
  [proxy release];

  [super dealloc];
}

@end
