// -*- Mode: objc; Coding: utf-8; indent-tabs-mode: nil; -*-

#import "OutlineView.h"

@implementation OutlineView

- (NSXMLElement*) castToNSXMLElement:(NSXMLNode*)node
{
  if ([node kind] != NSXMLElementKind) return nil;
  return (NSXMLElement*)(node);
}

- (NSMutableDictionary*) parseItemTag:(NSXMLElement*)item
{
  NSMutableDictionary* dict = [NSMutableDictionary new];
  NSMutableString* name = [NSMutableString new];
  int height = 0;

  NSUInteger count = [item childCount];
  for (NSUInteger i = 0; i < count; ++i) {
    NSXMLElement* e = [self castToNSXMLElement:[item childAtIndex:i]];
    if (! e) continue;

    if ([[e name] isEqualToString:@"item"]) {
      NSMutableDictionary* child = [self parseItemTag:e];
      NSMutableArray* children = dict[@"children"];
      if (! children) {
        children = [NSMutableArray new];
      }
      [children addObject:child];
      dict[@"children"] = children;

    } else if ([[e name] isEqualToString:@"name"]) {
      [name appendString:[e stringValue]];
      ++height;

    } else if ([[e name] isEqualToString:@"appendix"]) {
      [name appendString:@"\n  "];
      [name appendString:[e stringValue]];
      ++height;

    } else {
      NSString* value = [[e stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
      dict[[e name]] = value;
    }
  }

  dict[@"name"] = name;
  dict[@"height"] = @(height);

  return dict;
}

- (void) loadXML:(NSString*)xmlpath
{
  NSURL* url = [NSURL fileURLWithPath:xmlpath];
  NSError* error = nil;
  NSXMLDocument* xmldocument = [[NSXMLDocument alloc] initWithContentsOfURL:url options:0 error:&error];
  if (! xmldocument) {
    NSLog(@"XML error %@", [error localizedDescription]);
    return;
  }

  NSXMLElement* root = [xmldocument rootElement];
  NSUInteger itemcount = [root childCount];
  for (NSUInteger i = 0; i < itemcount; ++i) {
    NSXMLElement* item = [self castToNSXMLElement:[root childAtIndex:i]];
    if (! item) continue;

    [datasource_ addObject:[self parseItemTag:item]];
  }
}

- (id) init
{
  self = [super init];

  if (self) {
    datasource_ = [NSMutableArray new];
  }

  return self;
}


// ------------------------------------------------------------
- (NSUInteger) outlineView:(NSOutlineView*)outlineView numberOfChildrenOfItem:(id)item
{
  NSArray* a = nil;

  // root object
  if (! item) {
    a = datasource_;
  } else {
    a = item[@"children"];
  }

  if (! a) return 0;
  return [a count];
}

- (id) outlineView:(NSOutlineView*)outlineView child:(NSUInteger)idx ofItem:(id)item
{
  NSArray* a = nil;

  // root object
  if (! item) {
    a = datasource_;
  } else {
    a = item[@"children"];
  }

  if (! a) return nil;
  if (idx >= [a count]) return nil;
  return a[idx];
}

- (BOOL) outlineView:(NSOutlineView*)outlineView isItemExpandable:(id)item
{
  NSArray* a = item[@"children"];
  return a ? YES : NO;
}

- (id) outlineView:(NSOutlineView*)outlineView objectValueForTableColumn:(NSTableColumn*)tableColumn byItem:(id)item
{
  NSString* identifier = [tableColumn identifier];
  return item[identifier];
}

@end
