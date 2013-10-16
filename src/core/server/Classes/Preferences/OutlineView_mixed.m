// -*- Mode: objc; Coding: utf-8; indent-tabs-mode: nil; -*-

#import "OutlineView_keycode.h"
#import "OutlineView_mixed.h"
#import "PreferencesManager.h"

@implementation OutlineView_mixed

- (id) init
{
  self = [super init];

  if (self) {
    [self loadXML:[[NSBundle mainBundle] pathForResource:@"checkbox" ofType:@"xml"]];
  }

  return self;
}

- (void) initialExpandCollapseTree
{
  for (NSDictionary* dict in datasource_) {
    if ([dict[@"expand"] isEqualToString:@"true"]) {
      [outlineview_ expandItem:dict];
    } else {
      [outlineview_ collapseItem:dict];
    }
  }
}

// ------------------------------------------------------------
- (id) outlineView:(NSOutlineView*)outlineView objectValueForTableColumn:(NSTableColumn*)tableColumn byItem:(id)item
{
  NSString* identifier = [tableColumn identifier];

  if ([identifier isEqualToString:@"enable"]) {
    NSButtonCell* cell = [tableColumn dataCell];
    if (! cell) return nil;

    NSString* name = item[@"name"];
    if (! name) return nil;

    [cell setTitle:name];

    NSString* enable = item[@"enable"];
    if (! enable) {
      [cell setImagePosition:NSNoImage];
      return nil;

    } else {
      [cell setImagePosition:NSImageLeft];

      return @([preferencesManager_ value:enable]);
    }

  } else if ([identifier isEqualToString:@"keycode"]) {
    NSString* keycode = item[@"keycode"];
    if (! keycode) return nil;

    return @([preferencesManager_ value:keycode]);

  } else if ([identifier isEqualToString:@"default"]) {
    NSString* keycode = item[@"keycode"];
    if (! keycode) return nil;

    int keycodevalue = [preferencesManager_ defaultValue:keycode];
    NSString* keycodename = [outlineView_keycode_ getKeyName:keycodevalue];

    return [NSString stringWithFormat:@"%d (%@)", keycodevalue, keycodename];
  }

  return nil;
}

- (void) outlineView:(NSOutlineView*)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn*)tableColumn byItem:(id)item
{
  NSString* identifier = [tableColumn identifier];

  if ([identifier isEqualToString:@"enable"]) {
    NSString* enable = item[@"enable"];
    if (enable) {
      int value = [preferencesManager_ value:enable];
      value = ! value;
      [preferencesManager_ setValueForName:value forName:enable];
    } else {
      // expand/collapse tree
      if ([outlineView isExpandable:item]) {
        if ([outlineView isItemExpanded:item]) {
          [outlineView collapseItem:item];
        } else {
          [outlineView expandItem:item];
        }
      }
    }

  } else if ([identifier isEqualToString:@"keycode"]) {
    NSString* keycode = item[@"keycode"];
    if (keycode) {
      [preferencesManager_ setValueForName:[object intValue] forName:keycode];
    }
  }
}

- (CGFloat) outlineView:(NSOutlineView*)outlineView heightOfRowByItem:(id)item
{
  CGFloat height = [outlineView rowHeight];

  NSNumber* number = item[@"height"];
  if (number) {
    CGFloat newheight = [outlineView rowHeight]* [number intValue];
    if (newheight > height) {
      height = newheight;
    }
  }

  return height;
}

@end
