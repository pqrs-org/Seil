#import "MainValueCellView.h"
#import "NotificationKeys.h"
#import "PreferencesManager.h"
#import "ServerObjects.h"

@implementation MainValueCellView

- (IBAction)valueChanged:(id)sender {
  NSDictionary* notificationUserInfo = @{
    kPreferencesChangedNotificationUserInfoKeyPreferencesChangedFromGUI : @YES,
  };

  [self.serverObjects.preferencesManager setValue:[self.textField.stringValue intValue]
                                          forName:self.settingIdentifier
                             notificationUserInfo:notificationUserInfo];
}

@end
