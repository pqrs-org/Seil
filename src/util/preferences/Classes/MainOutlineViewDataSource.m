#import "MainOutlineViewDataSource.h"
#import "MainConfigurationTree.h"
#import "ServerClient.h"

@interface MainOutlineViewDataSource ()

@property(weak) IBOutlet ServerClient* client;
@property(copy, readwrite) MainConfigurationTree* source;

@end

@implementation MainOutlineViewDataSource

- (void)setup {
  self.source = [self.client.proxy mainConfigurationTree];
}

- (NSInteger)outlineView:(NSOutlineView*)outlineView numberOfChildrenOfItem:(id)item {
  MainConfigurationTree* tree = item ? item : self.source;
  if (!tree) return 0;

  return [tree.children count];
}

- (id)outlineView:(NSOutlineView*)outlineView child:(NSInteger)index ofItem:(id)item {
  MainConfigurationTree* tree = item ? item : self.source;
  if (!tree) return nil;

  if (0 <= index && index < (NSInteger)([tree.children count])) {
    return tree.children[index];
  }
  return nil;
}

- (BOOL)outlineView:(NSOutlineView*)outlineView isItemExpandable:(id)item {
  MainConfigurationTree* tree = item ? item : self.source;
  if (!tree) return NO;

  return [tree.children count] > 0;
}

@end
