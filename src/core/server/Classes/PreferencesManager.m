#import "PreferencesManager.h"
#import "PCKeyboardHackKeys.h"
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
  [default_ setObject:[NSNumber numberWithInt:51]  forKey:@"keycode_capslock"];
  [default_ setObject:[NSNumber numberWithInt:54]  forKey:@"keycode_jis_kana"];
  [default_ setObject:[NSNumber numberWithInt:102] forKey:@"keycode_jis_nfer"];
  [default_ setObject:[NSNumber numberWithInt:104] forKey:@"keycode_jis_xfer"];
  [default_ setObject:[NSNumber numberWithInt:55]  forKey:@"keycode_command_l"];
  [default_ setObject:[NSNumber numberWithInt:54]  forKey:@"keycode_command_r"];
  [default_ setObject:[NSNumber numberWithInt:59]  forKey:@"keycode_control_l"];
  [default_ setObject:[NSNumber numberWithInt:62]  forKey:@"keycode_control_r"];
  [default_ setObject:[NSNumber numberWithInt:58]  forKey:@"keycode_option_l"];
  [default_ setObject:[NSNumber numberWithInt:61]  forKey:@"keycode_option_r"];
  [default_ setObject:[NSNumber numberWithInt:56]  forKey:@"keycode_shift_l"];
  [default_ setObject:[NSNumber numberWithInt:60]  forKey:@"keycode_shift_r"];
  [default_ setObject:[NSNumber numberWithInt:53]  forKey:@"keycode_escape"];
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

    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:kPCKeyboardHackServerLaunchedNotification object:kPCKeyboardHackNotificationKey];
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

  [[NSDistributedNotificationCenter defaultCenter] postNotificationName:kPCKeyboardHackPreferencesChangedNotification object:kPCKeyboardHackNotificationKey];
}

// ----------------------------------------------------------------------
- (NSString*) preferencepane_version
{
  return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

@end
