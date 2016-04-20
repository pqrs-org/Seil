#import "KnownTableViewDataSource.h"
#import "KnownKeyCode.h"
#import "ServerClient.h"

@interface KnownTableViewDataSource ()

@property(weak) IBOutlet ServerClient* client;
@property(copy, readwrite) NSArray* source;

@end

@implementation KnownTableViewDataSource

- (void)setup {
  self.source = [self.client.proxy knownKeyCodes];
}

- (NSString*)getKeyName:(int)keycode {
  NSString* keycodestring = [@(keycode) stringValue];

  for (KnownKeyCode* knownKeyCode in self.source) {
    if ([keycodestring isEqualToString:knownKeyCode.keyCode]) {
      return knownKeyCode.name;
    }
  }
  return nil;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView*)aTableView {
  return (NSInteger)([self.source count]);
}

@end
