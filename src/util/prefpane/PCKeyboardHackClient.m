#import "PCKeyboardHackClient.h"
#import "PCKeyboardHackKeys.h"
#import "PCKeyboardHackNSDistributedNotificationCenter.h"

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

- (void) distributedObserver_serverLaunched:(NSNotification*)notification
{
  // [NSAutoreleasePool drain] is never called from NSDistributedNotificationCenter.
  // Therefore, we need to make own NSAutoreleasePool.
  NSAutoreleasePool* pool = [NSAutoreleasePool new];
  {
    NSLog(@"distributedObserver_serverLaunched called");
    [self refresh_connection];
  }
  [pool drain];
}

- (id) init
{
  self = [super init];

  if (self) {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(observer_NSConnectionDidDieNotification:)
                                                 name:NSConnectionDidDieNotification
                                               object:nil];

    [org_pqrs_PCKeyboardHack_NSDistributedNotificationCenter addObserver:self
                                                                selector:@selector(distributedObserver_serverLaunched:)
                                                                    name:kPCKeyboardHackServerLaunchedNotification];

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
