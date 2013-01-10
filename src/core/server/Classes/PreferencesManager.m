#import "NotificationKeys.h"
#import "PreferencesKeys.h"
#import "PreferencesManager.h"

@implementation PreferencesManager

// ----------------------------------------
+ (void) initialize
{
  NSDictionary* dict = @ { kCheckForUpdates : @1 };
  [[NSUserDefaults standardUserDefaults] registerDefaults:dict];
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
  }

  return self;
}

- (void) dealloc
{
  [default_ release];

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
  // [[NSUserDefaults standardUserDefaults] synchronize];

  [[NSNotificationCenter defaultCenter] postNotificationName:kPreferencesChangedNotification object:nil];
}

// ----------------------------------------------------------------------
- (NSInteger) checkForUpdatesMode
{
  return [[NSUserDefaults standardUserDefaults] integerForKey:kCheckForUpdates];
}

@end
