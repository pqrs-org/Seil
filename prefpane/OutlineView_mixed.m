// -*- Mode: objc; Coding: utf-8; indent-tabs-mode: nil; -*-

#import "OutlineView_mixed.h"
#import "SysctlWrapper.h"
#import "Common.h"

@implementation OutlineView_mixed

- (id)init
{
  self = [super init];
  if (self) {
    _xmlTreeWrapper = [[XMLTreeWrapper alloc] init];
    if (_xmlTreeWrapper == nil) return nil;
    if (! [_xmlTreeWrapper load:@"/Library/org.pqrs/PCKeyboardHack/prefpane/sysctl.xml"]) return nil;
    [_outlineView reloadData];
  }
  return self;
}

// ------------------------------------------------------------
- (int) outlineView:(NSOutlineView*)outlineView numberOfChildrenOfItem:(id)item
{
  return [_xmlTreeWrapper numberOfChildren:item];
}

- (id) outlineView:(NSOutlineView*)outlineView child:(int)index ofItem:(id)item
{
  return [_xmlTreeWrapper getChild:item index:index];
}

- (BOOL) outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
  return [_xmlTreeWrapper isItemExpandable:item];
}

- (BOOL) checkAnyChildrenChecked:(NSXMLNode *)node
{
  NSArray *a = [node nodesForXPath:@"list/item" error:NULL];
  if (a == nil) return FALSE;
  if ([a count] == 0) return FALSE;

  NSEnumerator *enumerator = [a objectEnumerator];
  NSXMLNode *n;
  while (n = [enumerator nextObject]) {
    if ([self checkAnyChildrenChecked:n]) return TRUE;

    NSXMLNode *sysctl = [_xmlTreeWrapper getNode:n xpath:@"enable"];
    if (sysctl) {
      NSNumber *value = [SysctlWrapper getInt:[sysctl stringValue]];
      if ([value boolValue]) return TRUE;
    }
  }

  return FALSE;
}

- (id)outlineView:(NSOutlineView*)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
  NSButtonCell *cell = [tableColumn dataCell];
  if (! cell) return nil;

  id identifier = [tableColumn identifier];
  if ([identifier isEqualToString:@"enable"]) {
    // ----------------------------------------
    // autoexpand
    if ([_outlineView isExpandable:item]) {
      if (! [_outlineView isItemExpanded:item]) {
        if ([self checkAnyChildrenChecked:item]) {
          [_outlineView expandItem:item];
        }
      }
    }

    NSXMLNode *title = [_xmlTreeWrapper getNode:item xpath:@"name"];
    if (! title) return nil;

    [cell setTitle:[title stringValue]];

    NSXMLNode *sysctl = [_xmlTreeWrapper getNode:item xpath:@"enable"];
    if (! sysctl) {
      [cell setImagePosition:NSNoImage];
      return nil;

    } else {
      [cell setImagePosition:NSImageLeft];
      return [SysctlWrapper getInt:[sysctl stringValue]];
    }

  } else if ([identifier isEqualToString:@"keycode"]) {
    NSXMLNode *sysctl = [_xmlTreeWrapper getNode:item xpath:@"keycode"];
    if (! sysctl) {
      return nil;
    } else {
      NSNumber *value = [SysctlWrapper getInt:[sysctl stringValue]];
      return value;
    }

  } else if ([identifier isEqualToString:@"default"]) {
    NSXMLNode *node = [_xmlTreeWrapper getNode:item xpath:@"default"];
    if (! node) {
      return nil;
    } else {
      return [node stringValue];
    }
  }

  return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldCollapseItem:(id)item
{
  return ! [self checkAnyChildrenChecked:item];
}

- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
  id identifier = [tableColumn identifier];
  if ([identifier isEqualToString:@"enable"]) {
    NSXMLNode *sysctl = [_xmlTreeWrapper getNode:item xpath:@"enable"];
    if (sysctl) {
      NSString *name = [sysctl stringValue];
      NSNumber *value = [SysctlWrapper getInt:name];
      NSNumber *new = [[[NSNumber alloc] initWithBool:![value boolValue]] autorelease];
      [Common setSysctlInt:name value:new];
    }
  } else if ([identifier isEqualToString:@"keycode"]) {
    NSXMLNode *sysctl = [_xmlTreeWrapper getNode:item xpath:@"keycode"];
    if (sysctl) {
      NSString *name = [sysctl stringValue];
      NSNumber *new = [[[NSNumber alloc] initWithInt:[object intValue]] autorelease];
      [Common setSysctlInt:name value:new];
    }
  }
}

@end
