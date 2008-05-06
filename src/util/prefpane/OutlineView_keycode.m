// -*- Mode: objc; Coding: utf-8; indent-tabs-mode: nil; -*-

#import "OutlineView_keycode.h"
#import "sharecode.h"

@implementation org_pqrs_PCKeyboardHack_OutlineView_keycode

static BUNDLEPREFIX_XMLTreeWrapper *_xmlTreeWrapper;

- (id) init
{
  self = [super init];
  if (! self) return self;

  _xmlTreeWrapper = [[BUNDLEPREFIX_XMLTreeWrapper alloc] init];
  if (_xmlTreeWrapper == nil) return nil;
  if (! [_xmlTreeWrapper load:@"/Library/org.pqrs/PCKeyboardHack/prefpane/keycode.xml"]) return nil;
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

- (id)outlineView:(NSOutlineView*)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
  id identifier = [tableColumn identifier];

  if ([identifier isEqualToString:@"name"] ||
      [identifier isEqualToString:@"keycode"]) {
    NSXMLNode *node = [_xmlTreeWrapper getNode:item xpath:identifier];
    if (! node) return nil;

    return [node stringValue];
  }

  return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldCollapseItem:(id)item
{
  return false;
}

@end
