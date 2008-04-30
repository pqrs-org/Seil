// -*- Mode: objc; Coding: utf-8; indent-tabs-mode: nil; -*-

#import "OutlineView_mixed.h"
#import "SysctlWrapper.h"
#import "Common.h"

@implementation OutlineView_mixed

static XMLTreeWrapper *_xmlTreeWrapper;

- (id) init
{
  self = [super init];
  if (! self) return self;

  _xmlTreeWrapper = [[XMLTreeWrapper alloc] init];
  if (_xmlTreeWrapper == nil) return nil;
  if (! [_xmlTreeWrapper load:@"/Library/org.pqrs/PCKeyboardHack/prefpane/sysctl.xml"]) return nil;
  return self;
}

- (IBAction) intelligentExpand:(id)sender
{
  for (;;) {
    bool nochange = true;

    int i = 0;
    for (i = 0; i < [_outlineView numberOfRows]; ++i) {
      id item = [_outlineView itemAtRow:i];
      if (! [_outlineView isExpandable:item]) continue;

      if ([self outlineView:_outlineView shouldCollapseItem:item]) {
        // collapse item
        if (! [_outlineView isItemExpanded:item]) continue;

        [_outlineView collapseItem:item];
        nochange = true;
        break;

      } else {
        // expand item
        if ([_outlineView isItemExpanded:item]) continue;

        [_outlineView expandItem:item];
        nochange = false;
        break;
      }
    }

    if (nochange) break;
  }
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
      NSString *entry = [NSString stringWithFormat:@"pckeyboardhack.%@", [sysctl stringValue]];
      NSNumber *value = [SysctlWrapper getInt:entry];
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
    NSXMLNode *title = [_xmlTreeWrapper getNode:item xpath:@"name"];
    if (! title) return nil;

    [cell setTitle:[title stringValue]];

    NSXMLNode *sysctl = [_xmlTreeWrapper getNode:item xpath:@"enable"];
    if (! sysctl) {
      [cell setImagePosition:NSNoImage];
      return nil;

    } else {
      [cell setImagePosition:NSImageLeft];

      NSString *entry = [NSString stringWithFormat:@"pckeyboardhack.%@", [sysctl stringValue]];
      return [SysctlWrapper getInt:entry];
    }

  } else if ([identifier isEqualToString:@"keycode"]) {
    NSXMLNode *sysctl = [_xmlTreeWrapper getNode:item xpath:@"keycode"];
    if (! sysctl) {
      return nil;
    } else {
      NSString *entry = [NSString stringWithFormat:@"pckeyboardhack.%@", [sysctl stringValue]];
      NSNumber *value = [SysctlWrapper getInt:entry];
      return value;
    }

  } else if ([identifier isEqualToString:@"default"]) {
    NSXMLNode *node = [_xmlTreeWrapper getNode:item xpath:@"default"];
    if (! node) {
      return nil;
    } else {
      NSXMLNode *appendix = [_xmlTreeWrapper getNode:item xpath:@"appendix"];
      if (appendix) {
        return [NSString stringWithFormat:@"%@ (%@)", [node stringValue], [appendix stringValue]];
      } else {
        return [node stringValue];
      }
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
      NSString *entry = [NSString stringWithFormat:@"pckeyboardhack.%@", name];
      NSNumber *value = [SysctlWrapper getInt:entry];
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
