#import "PreferencesManager.h"
#import "NotificationKeys.h"
#import "PreferencesKeys.h"
#import "PreferencesModel.h"
#import "SharedKeys.h"

@interface PreferencesManager ()

@property(weak) IBOutlet PreferencesModel* preferencesModel;
@property(copy) NSDictionary* defaults;

@end

@implementation PreferencesManager

+ (void)initialize {
  NSDictionary* dict = @{
    kCheckForUpdates : @YES,
    kShowIconInDock : @NO,
    kResumeAtLogin : @YES,
    kPreferencesValues : @{},
  };
  [[NSUserDefaults standardUserDefaults] registerDefaults:dict];
}

- (void)loadPreferencesModel:(PreferencesModel*)preferencesModel {
  preferencesModel.resumeAtLogin = [[NSUserDefaults standardUserDefaults] boolForKey:kResumeAtLogin];
  preferencesModel.checkForUpdates = [[NSUserDefaults standardUserDefaults] boolForKey:kCheckForUpdates];

  NSMutableDictionary* values = [NSMutableDictionary dictionaryWithDictionary:self.defaults];
  NSDictionary* preferencesValues = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kPreferencesValues];
  for (NSString* key in preferencesValues) {
    values[key] = preferencesValues[key];
  }
  preferencesModel.values = values;
}

- (void)savePreferencesModel:(PreferencesModel*)preferencesModel processIdentifier:(int)processIdentifier {
  [[NSUserDefaults standardUserDefaults] setObject:@(preferencesModel.resumeAtLogin) forKey:kResumeAtLogin];
  [[NSUserDefaults standardUserDefaults] setObject:@(preferencesModel.checkForUpdates) forKey:kCheckForUpdates];

  NSMutableDictionary* values = [NSMutableDictionary dictionaryWithDictionary:preferencesModel.values];
  for (NSString* key in self.defaults) {
    if ([self.defaults[key] intValue] == [values[key] intValue]) {
      [values removeObjectForKey:key];
    }
  }
  [[NSUserDefaults standardUserDefaults] setObject:values forKey:kPreferencesValues];

  // ----------------------------------------
  // refresh local model.
  if (preferencesModel != self.preferencesModel) {
    [self loadPreferencesModel:self.preferencesModel];
  }

  // ----------------------------------------
  [[NSNotificationCenter defaultCenter] postNotificationName:kPreferencesChangedNotification object:nil];
  [[NSDistributedNotificationCenter defaultCenter] postNotificationName:kSeilPreferencesUpdatedNotification
                                                                 object:nil
                                                               userInfo:@{ @"processIdentifier" : @(processIdentifier) }
                                                     deliverImmediately:YES];
}

- (NSDictionary*)export {
  return [[NSUserDefaults standardUserDefaults] dictionaryForKey:kPreferencesValues];
}

// ----------------------------------------
- (id)init {
  self = [super init];

  if (self) {
    self.defaults = @{
#include "defaults.h"
    };
  }

  return self;
}

// ----------------------------------------------------------------------
- (int)value:(NSString*)name {
  NSString* identifier = @"sysctl";

  NSDictionary* dict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:identifier];
  if (dict) {
    NSNumber* number = dict[name];
    if (number) {
      return [number intValue];
    }
  }
  return [self defaultValue:name];
}

- (int)defaultValue:(NSString*)name {
  NSNumber* number = self.defaults[name];
  if (number) {
    return [number intValue];
  } else {
    return 0;
  }
}

- (void)setValue:(int)newval forName:(NSString*)name {
  [self setValue:newval forName:name notificationUserInfo:nil];
}

- (void)setValue:(int)newval forName:(NSString*)name notificationUserInfo:(NSDictionary*)notificationUserInfo {
  NSString* identifier = @"sysctl";

  NSMutableDictionary* md = nil;

  NSDictionary* dict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:identifier];
  if (dict) {
    md = [NSMutableDictionary dictionaryWithDictionary:dict];
  } else {
    md = [NSMutableDictionary new];
  }
  if (!md) return;

  int defaultvalue = 0;
  NSNumber* defaultnumber = self.defaults[name];
  if (defaultnumber) {
    defaultvalue = [defaultnumber intValue];
  }

  if (newval == defaultvalue) {
    [md removeObjectForKey:name];
  } else {
    md[name] = @(newval);
  }

  [[NSUserDefaults standardUserDefaults] setObject:md forKey:identifier];
  // [[NSUserDefaults standardUserDefaults] synchronize];

  [[NSNotificationCenter defaultCenter] postNotificationName:kPreferencesChangedNotification object:nil userInfo:notificationUserInfo];
}

// ----------------------------------------------------------------------
- (BOOL)isCheckForUpdates {
  return [[NSUserDefaults standardUserDefaults] boolForKey:kCheckForUpdates];
}

@end
