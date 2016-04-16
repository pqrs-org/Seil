#import "MainValueCellView.h"
#import "PreferencesModel.h"
#import "PreferencesWindowController.h"

@implementation MainValueCellView

- (IBAction)valueChanged:(id)sender {
  [self.preferencesModel setValue:[self.textField.stringValue intValue] forName:self.settingIdentifier];
  [self.preferencesWindowController savePreferencesModel];
}

@end
