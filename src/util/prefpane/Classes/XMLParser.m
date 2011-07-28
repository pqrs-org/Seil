// -*- Mode: objc; Coding: utf-8; indent-tabs-mode: nil; -*-

#import "XMLParser.h"

@implementation org_pqrs_PCKeyboardHack_XMLParser

- (NSXMLElement*) castToNSXMLElement:(NSXMLNode*)node
{
  if ([node kind] != NSXMLElementKind) return nil;
  return (NSXMLElement*)(node);
}

- (NSMutableDictionary*) parseItemTag:(NSXMLElement*)item
{
  NSMutableDictionary* dict = [[NSMutableDictionary new] autorelease];

  NSUInteger count = [item childCount];
  for (NSUInteger i = 0; i < count; ++i) {
    NSXMLElement* e = [self castToNSXMLElement:[item childAtIndex:i]];
    if (! e) continue;

    if ([[e name] isEqualToString:@"item"]) {
      NSMutableDictionary* child = [self parseItemTag:e];
      NSMutableArray* children = [dict objectForKey:@"children"];
      if (! children) {
        children = [[NSMutableArray new] autorelease];
      }
      [children addObject:child];
      [dict setObject:children forKey:@"children"];

    } else {
      NSString* value = [[e stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
      [dict setObject:value forKey:[e name]];
    }
  }

  return dict;
}

- (void) loadXML:(NSString*)xmlpath
{
  NSURL* url = [NSURL fileURLWithPath:xmlpath];
  NSError* error = nil;
  NSXMLDocument* xmldocument = [[[NSXMLDocument alloc] initWithContentsOfURL:url options:0 error:&error] autorelease];
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

- (void) dealloc
{
  [datasource_ release];

  [super dealloc];
}

@end
