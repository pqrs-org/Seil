#import "MainNameCellView.h"
#import "MainOutlineView.h"
#import "MainOutlineViewDataSource.h"

@interface MainOutlineView ()

@property(weak) NSTableCellView* mouseDownCellView;

@end

@implementation MainOutlineView

- (BOOL)validateProposedFirstResponder:(NSResponder*)responder forEvent:(NSEvent*)event {
  return YES;
}

- (void)mouseDown:(NSEvent*)theEvent {
  NSPoint point = [self convertPoint:theEvent.locationInWindow fromView:nil];
  NSInteger row = [self rowAtPoint:point];
  NSInteger column = [self columnAtPoint:point];
  if (column == 0 && row >= 0) {
    self.mouseDownCellView = [self viewAtColumn:column row:row makeIfNecessary:NO];
  } else {
    self.mouseDownCellView = nil;
  }
}

- (void)mouseUp:(NSEvent*)theEvent {
  NSPoint point = [self convertPoint:theEvent.locationInWindow fromView:nil];
  NSInteger row = [self rowAtPoint:point];
  NSInteger column = [self columnAtPoint:point];
  if (column == 0 && row >= 0) {
    MainNameCellView* view = [self viewAtColumn:column row:row makeIfNecessary:NO];
    if (self.mouseDownCellView == view) {
      // clicked
      NSDictionary* item = [self itemAtRow:row];
      if ([self isExpandable:item]) {
        if ([self isItemExpanded:item]) {
          if ([self selectedRow] == row) {
            [self collapseItem:item];
          } else {
            [self selectRowIndexes:[NSIndexSet indexSetWithIndex:(NSUInteger)(row)] byExtendingSelection:NO];
          }
        } else {
          [self selectRowIndexes:[NSIndexSet indexSetWithIndex:(NSUInteger)(row)] byExtendingSelection:NO];
          [self expandItem:item];
        }
        [[self window] makeFirstResponder:self];
      } else {
        [view toggle];
      }
    }
  }
  self.mouseDownCellView = nil;
}

- (void)initialExpandCollapseTree {
  MainOutlineViewDataSource* dataSource = (MainOutlineViewDataSource*)(self.dataSource);
  for (NSDictionary* dict in dataSource.source) {
    if ([dict[@"expand"] isEqualToString:@"true"]) {
      [self expandItem:dict];
    }
  }
}

@end
