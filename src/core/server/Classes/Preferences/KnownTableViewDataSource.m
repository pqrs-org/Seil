#import "KnownTableViewDataSource.h"
#import "XMLLoader.h"

@interface KnownTableViewDataSource ()

@property(copy, readwrite) NSArray* source;

@end

@implementation KnownTableViewDataSource

- (instancetype)init {
  self = [super init];

  if (self) {
    self.source = [XMLLoader load:[[NSBundle mainBundle] pathForResource:@"known" ofType:@"xml"]];
  }

  return self;
}

- (NSString*)getKeyName:(int)keycode {
  NSString* keycodestring = [NSString stringWithFormat:@"%d", keycode];

  for (NSDictionary* dict in self.source) {
    if ([keycodestring isEqualToString:dict[@"keycode"]]) {
      return dict[@"name"];
    }
  }
  return nil;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView*)aTableView {
  return (NSInteger)([self.source count]);
}

@end
