#import "MainOutlineViewDataSource.h"
#import "XMLLoader.h"

@interface MainOutlineViewDataSource ()

@property(copy, readwrite) NSArray* source;

@end

@implementation MainOutlineViewDataSource

- (instancetype)init {
  self = [super init];

  if (self) {
    self.source = [XMLLoader load:[[NSBundle mainBundle] pathForResource:@"checkbox" ofType:@"xml"]];
  }

  return self;
}

- (NSInteger)outlineView:(NSOutlineView*)outlineView numberOfChildrenOfItem:(id)item {
  return item ? [item[@"children"] count] : [self.source count];
}

- (id)outlineView:(NSOutlineView*)outlineView child:(NSInteger)index ofItem:(id)item {
  NSArray* a = item ? item[@"children"] : self.source;

  if (0 <= index && index < (NSInteger)([a count])) {
    return a[index];
  }
  return nil;
}

- (BOOL)outlineView:(NSOutlineView*)outlineView isItemExpandable:(id)item {
  return [item[@"children"] count] > 0;
}

@end
