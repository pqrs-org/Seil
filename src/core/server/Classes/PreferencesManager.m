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

- (instancetype)init {
  self = [super init];

  if (self) {
    self.defaults = @{
#include "defaults.h"
    };
  }

  return self;
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

@end
