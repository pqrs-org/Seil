#import "PreferencesManager.h"
#import "PCKeyboardHackKeys.h"
#import "PCKeyboardHackNSDistributedNotificationCenter.h"
#include <sys/time.h>

static PreferencesManager* global_instance = nil;

@implementation PreferencesManager

+ (PreferencesManager*) getInstance
{
  @synchronized(self) {
    if (! global_instance) {
      global_instance = [PreferencesManager new];
    }
  }
  return global_instance;
}

// ----------------------------------------
- (void) setDefault
{
#include "setDefault.h"
}

// ----------------------------------------
- (id) init
{
  self = [super init];

  if (self) {
    default_ = [NSMutableDictionary new];
    [self setDefault];

    // ------------------------------------------------------------
    serverconnection_ = [NSConnection new];
    [serverconnection_ setRootObject:self];
    [serverconnection_ registerName:kPCKeyboardHackConnectionName];

    [org_pqrs_PCKeyboardHack_NSDistributedNotificationCenter postNotificationName:kPCKeyboardHackServerLaunchedNotification userInfo:nil];
  }

  return self;
}

- (void) dealloc
{
  [default_ release];
  [serverconnection_ release];

  [super dealloc];
}

// ----------------------------------------------------------------------
- (int) value:(NSString*)name
{
  NSString* identifier = @"sysctl";

  NSDictionary* dict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:identifier];
  if (dict) {
    NSNumber* number = [dict objectForKey:name];
    if (number) {
      return [number intValue];
    }
  }
  return [self defaultValue:name];
}

- (int) defaultValue:(NSString*)name
{
  NSNumber* number = [default_ objectForKey:name];
  if (number) {
    return [number intValue];
  } else {
    return 0;
  }
}

- (void) setValueForName:(int)newval forName:(NSString*)name
{
  NSString* identifier = @"sysctl";

  NSMutableDictionary* md = nil;

  NSDictionary* dict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:identifier];
  if (dict) {
    md = [NSMutableDictionary dictionaryWithDictionary:dict];
  } else {
    md = [[NSMutableDictionary new] autorelease];
  }
  if (! md) return;

  int defaultvalue = 0;
  NSNumber* defaultnumber = [default_ objectForKey:name];
  if (defaultnumber) {
    defaultvalue = [defaultnumber intValue];
  }

  if (newval == defaultvalue) {
    [md removeObjectForKey:name];
  } else {
    [md setObject:[NSNumber numberWithInt:newval] forKey:name];
  }

  [[NSUserDefaults standardUserDefaults] setObject:md forKey:identifier];
  //[[NSUserDefaults standardUserDefaults] synchronize];

  [org_pqrs_PCKeyboardHack_NSDistributedNotificationCenter postNotificationName:kPCKeyboardHackPreferencesChangedNotification userInfo:nil];
}

// ----------------------------------------------------------------------
- (NSInteger) checkForUpdatesMode
{
  // If the key does not exist, treat as "The stable release only".
  if (! [[NSUserDefaults standardUserDefaults] objectForKey:@"isCheckUpdate"]) {
    return 1;
  }
  return [[NSUserDefaults standardUserDefaults] integerForKey:@"isCheckUpdate"];
}

- (void) setCheckForUpdatesMode:(NSInteger)newval
{
  [[NSUserDefaults standardUserDefaults] setInteger:newval forKey:@"isCheckUpdate"];
  //[[NSUserDefaults standardUserDefaults] synchronize];
}

// ----------------------------------------------------------------------
- (NSString*) preferencepane_version
{
  return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

@end
