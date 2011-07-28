// -*- Mode: objc; Coding: utf-8; indent-tabs-mode: nil; -*-

#import "OutlineView_keycode.h"

@implementation org_pqrs_PCKeyboardHack_OutlineView_keycode

- (NSXMLElement*) castToNSXMLElement:(NSXMLNode*)node
{
  if ([node kind] != NSXMLElementKind) return nil;
  return (NSXMLElement*)(node);
}

- (void) loadXML
{
  NSString* xmlpath = @"/Library/org.pqrs/PCKeyboardHack/prefpane/known.xml";
  NSURL* url = [NSURL fileURLWithPath:xmlpath];
  NSError* error = nil;
  NSXMLDocument* xmldocument = [[[NSXMLDocument alloc] initWithContentsOfURL:url options:0 error:&error] autorelease];
  if (! xmldocument) {
    NSLog(@"XML error %@", [error localizedDescription]);
  }

  NSXMLElement* root = [xmldocument rootElement];
  NSUInteger itemcount = [root childCount];
  for (NSUInteger i = 0; i < itemcount; ++i) {
    NSXMLElement* item = [self castToNSXMLElement:[root childAtIndex:i]];
    if (! item) continue;

    NSMutableDictionary* dict = [[NSMutableDictionary new] autorelease];

    NSUInteger count = [item childCount];
    for (NSUInteger j = 0; j < count; ++j) {
      NSXMLElement* e = [self castToNSXMLElement:[item childAtIndex:j]];
      if (! e) continue;

      NSString* value = [[e stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
      [dict setObject:value forKey:[e name]];
    }

    if ([dict count] > 0) {
      [keycode_ addObject:dict];
    }
  }
}

- (id) init
{
  self = [super init];
  if (self) {
    keycode_ = [NSMutableArray new];
    [self loadXML];

    return self;
  }
  return self;
}

- (void) dealloc
{
  [keycode_ release];

  [super dealloc];
}

- (NSString*) getKeyName:(int)keycode
{
  NSString* keycodestring = [NSString stringWithFormat:@"%d", keycode];

  for (NSDictionary* dict in keycode_) {
    if ([keycodestring isEqualToString:[dict objectForKey:@"keycode"]]) {
      return [dict objectForKey:@"name"];
    }
  }
  return nil;
}

// ------------------------------------------------------------
- (NSUInteger) outlineView:(NSOutlineView*)outlineView numberOfChildrenOfItem:(id)item
{
  // root object
  if (! item) {
    return [keycode_ count];
  }

  return 0;
}

- (id) outlineView:(NSOutlineView*)outlineView child:(NSUInteger)idx ofItem:(id)item
{
  // root object
  if (! item) {
    return [keycode_ objectAtIndex:idx];
  }

  return nil;
}

- (BOOL) outlineView:(NSOutlineView*)outlineView isItemExpandable:(id)item
{
  return NO;
}

- (id) outlineView:(NSOutlineView*)outlineView objectValueForTableColumn:(NSTableColumn*)tableColumn byItem:(id)item
{
  id identifier = [tableColumn identifier];

  if ([identifier isEqualToString:@"name"]) {
    return [item objectForKey:@"name"];

  } else if ([identifier isEqualToString:@"keycode"]) {
    return [item objectForKey:@"keycode"];
  }

  return nil;
}

- (BOOL) outlineView:(NSOutlineView*)outlineView shouldCollapseItem:(id)item
{
  return NO;
}

@end
