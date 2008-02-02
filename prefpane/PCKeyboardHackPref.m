// -*- Mode: objc; Coding: utf-8; indent-tabs-mode: nil; -*-

#import "PCKeyboardHackPref.h"

@implementation PCKeyboardHackPref

- (void) loadXML
{
  NSString *path = @"/Applications/PCKeyboardHack/prefpane/sysctl.xml";
  NSURL *url = [NSURL fileURLWithPath:path];
  _XMLDocument = [[NSXMLDocument alloc] initWithContentsOfURL:url options:0 error:NULL];
}

- (void) drawVersion
{
  NSString *version = [_sysctlWrapper getString:@"pckeyboardhack.version"];
  if (! version) {
    version = @"-.-.-";
  }
  [_versionText setStringValue:version];
}

- (void) mainViewDidLoad
{
  _XMLDocument = nil;
  _sysctlWrapper = [[SysctlWrapper alloc] init];
  _adminAction = [[AdminAction alloc] init];

  [self loadXML];
  if (! _XMLDocument) return;

  [self drawVersion];

  [_outlineView reloadData];
}

// ----------------------------------------------------------------------
// for NSOutlineView
- (id) normalizeItem:(id) item
{
  if (! _XMLDocument) return nil;

  if (! item) {
    return [_XMLDocument rootElement];
  }
  return item;
}

- (int) numberOfChildren:(id) item
{
  item = [self normalizeItem:item];
  if (! item) return 0;

  NSArray *nodes = [item nodesForXPath:@"list/item" error:NULL];
  return [nodes count];
}

- (int) outlineView:(NSOutlineView*)outlineView numberOfChildrenOfItem:(id)item
{
  return [self numberOfChildren:item];
}

- (id) outlineView:(NSOutlineView*)outlineView child:(int)index ofItem:(id)item
{
  item = [self normalizeItem:item];
  if (! item) return 0;

  NSArray *nodes = [item nodesForXPath:@"list/item" error:NULL];
  return [nodes objectAtIndex:index];
}

- (BOOL) outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
  item = [self normalizeItem:item];
  if (! item) return 0;

  return [self numberOfChildren:item] > 0;
}

- (NSXMLNode *) getNode:(NSXMLNode *)node xpath:(NSString *)xpath
{
  NSArray *a = [node nodesForXPath:xpath error:NULL];
  if (a == nil) return nil;
  if ([a count] == 0) return nil;

  return [a objectAtIndex:0];
}

- (BOOL) checkAnyChildrenChecked:(NSXMLNode *)node
{
  NSArray *a = [node nodesForXPath:@".//enable" error:NULL];
  if (a == nil) return FALSE;
  if ([a count] == 0) return FALSE;

  NSEnumerator *enumerator = [a objectEnumerator];
  NSXMLNode *n;
  while (n = [enumerator nextObject]) {
    NSNumber *value = [_sysctlWrapper getInt:[n stringValue]];
    if ([value boolValue]) return TRUE;
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

    NSXMLNode *title = [self getNode:item xpath:@"name"];
    if (! title) return nil;

    [cell setTitle:[title stringValue]];

    NSXMLNode *sysctl = [self getNode:item xpath:@"enable"];
    if (! sysctl) {
      [cell setImagePosition:NSNoImage];
      return nil;

    } else {
      [cell setImagePosition:NSImageLeft];
      return [_sysctlWrapper getInt:[sysctl stringValue]];
    }

  } else if ([identifier isEqualToString:@"keycode"]) {
    NSXMLNode *sysctl = [self getNode:item xpath:@"keycode"];
    if (! sysctl) {
      return nil;
    } else {
      NSNumber *value = [_sysctlWrapper getInt:[sysctl stringValue]];
      return value;
    }

  } else if ([identifier isEqualToString:@"default"]) {
    NSXMLNode *node = [self getNode:item xpath:@"default"];
    if (! node) {
      return nil;
    } else {
      return [node stringValue];
    }
  }

  return nil;
}

- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
  NSLog(@"setObjectValue");
  id identifier = [tableColumn identifier];
  if ([identifier isEqualToString:@"enable"]) {
    NSXMLNode *sysctl = [self getNode:item xpath:@"enable"];
    if (sysctl) {
      NSString *name = [sysctl stringValue];
      NSNumber *value = [_sysctlWrapper getInt:name];
      NSNumber *new = [[[NSNumber alloc] initWithBool:![value boolValue]] autorelease];
      [_adminAction setSysctlInt:name value:new];
    }
  } else if ([identifier isEqualToString:@"keycode"]) {
    NSXMLNode *sysctl = [self getNode:item xpath:@"keycode"];
    if (sysctl) {
      NSString *name = [sysctl stringValue];
      NSNumber *new = [[[NSNumber alloc] initWithInt:[object intValue]] autorelease];
      [_adminAction setSysctlInt:name value:new];
    }
  }
}

@end
