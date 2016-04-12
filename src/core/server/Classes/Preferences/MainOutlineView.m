#import "MainOutlineView.h"
#import "MainNameCellView.h"
#import "MainOutlineViewDataSource.h"

@interface MainOutlineView ()

@property(weak) NSTableCellView* mouseDownCellView;

@end

@implementation MainOutlineView

- (BOOL)validateProposedFirstResponder:(NSResponder*)responder forEvent:(NSEvent*)event {
  NSPoint point = [self convertPoint:event.locationInWindow fromView:nil];
  NSInteger column = [self columnAtPoint:point];
  if (column == 2) {
    return YES;
  } else {
    return NO;
  }
}

- (BOOL)acceptsFirstMouse:(NSEvent*)theEvent {
  return NO;
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
      } else {
        [view toggle];
      }
      [[self window] makeFirstResponder:self];
    }
  }
  self.mouseDownCellView = nil;
}

@end
