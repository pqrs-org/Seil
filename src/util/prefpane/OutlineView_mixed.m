// -*- Mode: objc; Coding: utf-8; indent-tabs-mode: nil; -*-

#import "OutlineView_mixed.h"
#import "sharecode.h"

@implementation org_pqrs_PCKeyboardHack_OutlineView_mixed

static BUNDLEPREFIX_XMLTreeWrapper *_xmlTreeWrapper;
static NSString *sysctl_set = @"/Library/org.pqrs/PCKeyboardHack/bin/PCKeyboardHack_sysctl_set";
static NSString *sysctl_ctl = @"/Library/org.pqrs/PCKeyboardHack/bin/PCKeyboardHack_sysctl_ctl";

- (id) init
{
  self = [super init];
  if (! self) return self;

  _xmlTreeWrapper = [[BUNDLEPREFIX_XMLTreeWrapper alloc] init];
  if (_xmlTreeWrapper == nil) return nil;
  if (! [_xmlTreeWrapper load:@"/Library/org.pqrs/PCKeyboardHack/prefpane/sysctl.xml"]) return nil;
  return self;
}

- (IBAction) expandALL:(id)sender
{
  [BUNDLEPREFIX_OutlineViewUtil expandALL:_outlineView_mixed];
}

- (IBAction) collapseALL:(id)sender
{
  [BUNDLEPREFIX_OutlineViewUtil collapseALL:_outlineView_mixed];
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
      NSNumber *value = [BUNDLEPREFIX_SysctlWrapper getInt:entry];
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
      return [BUNDLEPREFIX_SysctlWrapper getInt:entry];
    }

  } else if ([identifier isEqualToString:@"keycode"]) {
    NSXMLNode *sysctl = [_xmlTreeWrapper getNode:item xpath:@"keycode"];
    if (! sysctl) {
      return nil;
    } else {
      NSString *entry = [NSString stringWithFormat:@"pckeyboardhack.%@", [sysctl stringValue]];
      NSNumber *value = [BUNDLEPREFIX_SysctlWrapper getInt:entry];
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

- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
  id identifier = [tableColumn identifier];
  if ([identifier isEqualToString:@"enable"]) {
    NSXMLNode *sysctl = [_xmlTreeWrapper getNode:item xpath:@"enable"];
    if (sysctl) {
      NSString *name = [sysctl stringValue];
      NSString *entry = [NSString stringWithFormat:@"pckeyboardhack.%@", name];
      NSNumber *value = [BUNDLEPREFIX_SysctlWrapper getInt:entry];
      NSNumber *new = [[[NSNumber alloc] initWithBool:![value boolValue]] autorelease];
      [BUNDLEPREFIX_Common setSysctlInt:@"pckeyboardhack" name:name value:new sysctl_set:sysctl_set sysctl_ctl:sysctl_ctl];
    }
  } else if ([identifier isEqualToString:@"keycode"]) {
    NSXMLNode *sysctl = [_xmlTreeWrapper getNode:item xpath:@"keycode"];
    if (sysctl) {
      NSString *name = [sysctl stringValue];
      NSNumber *new = [[[NSNumber alloc] initWithInt:[object intValue]] autorelease];
      [BUNDLEPREFIX_Common setSysctlInt:@"pckeyboardhack" name:name value:new sysctl_set:sysctl_set sysctl_ctl:sysctl_ctl];
    }
  }
}

@end
