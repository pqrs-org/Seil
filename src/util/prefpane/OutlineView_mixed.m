// -*- Mode: objc; Coding: utf-8; indent-tabs-mode: nil; -*-

#import "OutlineView_mixed.h"
#import "XMLTreeWrapper.h"

@implementation org_pqrs_PCKeyboardHack_OutlineView_mixed

static BUNDLEPREFIX(XMLTreeWrapper) * _xmlTreeWrapper;

- (id) init
{
  self = [super init];
  if (! self) return self;

  _xmlTreeWrapper = [[BUNDLEPREFIX (XMLTreeWrapper) alloc] init];
  if (_xmlTreeWrapper == nil) return nil;
  if (! [_xmlTreeWrapper load:@"/Library/org.pqrs/PCKeyboardHack/prefpane/sysctl.xml"]) return nil;
  return self;
}

// ------------------------------------------------------------
- (NSUInteger) outlineView:(NSOutlineView*)outlineView numberOfChildrenOfItem:(id)item
{
  return [_xmlTreeWrapper numberOfChildren:item];
}

- (id) outlineView:(NSOutlineView*)outlineView child:(NSUInteger)idx ofItem:(id)item
{
  return [_xmlTreeWrapper getChild:item index:idx];
}

- (BOOL) outlineView:(NSOutlineView*)outlineView isItemExpandable:(id)item
{
  return [_xmlTreeWrapper isItemExpandable:item];
}

- (id) outlineView:(NSOutlineView*)outlineView objectValueForTableColumn:(NSTableColumn*)tableColumn byItem:(id)item
{
  NSButtonCell* cell = [tableColumn dataCell];
  if (! cell) return nil;

  id identifier = [tableColumn identifier];
  if ([identifier isEqualToString:@"enable"]) {
    NSXMLNode* title = [_xmlTreeWrapper getNode:item xpath:@"name"];
    if (! title) return nil;

    [cell setTitle:[title stringValue]];

    NSXMLNode* sysctl = [_xmlTreeWrapper getNode:item xpath:@"enable"];
    if (! sysctl) {
      [cell setImagePosition:NSNoImage];
      return nil;

    } else {
      [cell setImagePosition:NSImageLeft];

      return [NSNumber numberWithInt:[[client_ proxy] value:[sysctl stringValue]]];
    }

  } else if ([identifier isEqualToString:@"keycode"]) {
    NSXMLNode* sysctl = [_xmlTreeWrapper getNode:item xpath:@"keycode"];
    if (! sysctl) {
      return nil;
    } else {
      return [NSNumber numberWithInt:[[client_ proxy] value:[sysctl stringValue]]];
    }

  } else if ([identifier isEqualToString:@"default"]) {
    NSXMLNode* node = [_xmlTreeWrapper getNode:item xpath:@"default"];
    if (! node) {
      return nil;
    } else {
      NSXMLNode* appendix = [_xmlTreeWrapper getNode:item xpath:@"appendix"];
      if (appendix) {
        return [NSString stringWithFormat:@"%@ (%@)", [node stringValue], [appendix stringValue]];
      } else {
        return [node stringValue];
      }
    }
  }

  return nil;
}

- (void) outlineView:(NSOutlineView*)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn*)tableColumn byItem:(id)item
{
  id identifier = [tableColumn identifier];
  if ([identifier isEqualToString:@"enable"]) {
    NSXMLNode* sysctl = [_xmlTreeWrapper getNode:item xpath:@"enable"];
    if (sysctl) {
      NSString* name = [sysctl stringValue];
      int value = [[client_ proxy] value:name];
      value = ! value;
      [[client_ proxy] setValueForName:value forName:identifier];
    }
  } else if ([identifier isEqualToString:@"keycode"]) {
    NSXMLNode* sysctl = [_xmlTreeWrapper getNode:item xpath:@"keycode"];
    if (sysctl) {
      NSString* name = [sysctl stringValue];
      [[client_ proxy] setValueForName:[object intValue] forName:name];
    }
  }
}

@end
