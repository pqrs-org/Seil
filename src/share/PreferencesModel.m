#import "PreferencesModel.h"

@implementation PreferencesModel

- (void)setValue:(int)newval forName:(NSString*)name {
  NSMutableDictionary* values = [NSMutableDictionary dictionaryWithDictionary:self.values];
  values[name] = @(newval);
  self.values = values;
}

@end
