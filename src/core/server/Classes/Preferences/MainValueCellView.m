#import "MainValueCellView.h"
#import "NotificationKeys.h"
#import "PreferencesModel.h"
#import "PreferencesWindowController.h"
#import "ServerObjects.h"

@implementation MainValueCellView

- (IBAction)valueChanged:(id)sender {
  [self.serverObjects.preferencesModel setValue:[self.textField.stringValue intValue] forName:self.settingIdentifier];
  [self.preferencesWindowController savePreferencesModel];
}

@end
