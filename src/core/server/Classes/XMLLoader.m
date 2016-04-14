#import "XMLLoader.h"
#import "KnownKeyCode.h"
#import "MainConfigurationTree.h"

@implementation XMLLoader

+ (NSXMLElement*)castToNSXMLElement:(NSXMLNode*)node {
  if ([node kind] != NSXMLElementKind) return nil;
  return (NSXMLElement*)(node);
}

+ (NSXMLDocument*)loadXMLDocument:(NSString*)filePath {
  NSURL* url = [NSURL fileURLWithPath:filePath];
  NSError* error = nil;
  NSXMLDocument* document = [[NSXMLDocument alloc] initWithContentsOfURL:url options:0 error:&error];
  if (!document) {
    NSLog(@"XML error %@", [error localizedDescription]);
  }
  return document;
}

+ (MainConfigurationTree*)loadMainConfiguration:(NSString*)filePath {
  NSXMLDocument* document = [XMLLoader loadXMLDocument:filePath];
  if (!document) {
    return nil;
  }

  NSXMLElement* root = [document rootElement];
  NSUInteger count = [root childCount];
  NSMutableArray* children = [NSMutableArray new];
  for (NSUInteger i = 0; i < count; ++i) {
    NSXMLElement* element = [XMLLoader castToNSXMLElement:[root childAtIndex:i]];
    if (!element) continue;

    MainConfigurationTree* tree = [XMLLoader parseMainConfigurationItem:element];
    [children addObject:tree];
  }

  return [[MainConfigurationTree alloc] initWithItem:nil children:children];
}

+ (NSArray*)loadKnownKeyCode:(NSString*)filePath {
  NSXMLDocument* document = [XMLLoader loadXMLDocument:filePath];
  if (!document) {
    return nil;
  }

  NSXMLElement* root = [document rootElement];
  NSUInteger count = [root childCount];
  NSMutableArray* children = [NSMutableArray new];
  for (NSUInteger i = 0; i < count; ++i) {
    NSXMLElement* element = [XMLLoader castToNSXMLElement:[root childAtIndex:i]];
    if (!element) continue;

    KnownKeyCode* node = [XMLLoader parseKnownKeyCodeItem:element];
    [children addObject:node];
  }

  return children;
}

+ (MainConfigurationTree*)parseMainConfigurationItem:(NSXMLElement*)element {
  NSMutableString* name = [NSMutableString new];
  NSString* style = nil;
  NSString* enableKey = nil;
  NSString* keyCodeKey = nil;
  int defaultKeyCode = 0;
  NSMutableArray* children = nil;

  NSUInteger count = [element childCount];
  for (NSUInteger i = 0; i < count; ++i) {
    NSXMLElement* e = [XMLLoader castToNSXMLElement:[element childAtIndex:i]];
    if (!e) continue;

    if ([[e name] isEqualToString:@"item"]) {
      MainConfigurationTree* child = [XMLLoader parseMainConfigurationItem:e];
      if (!children) {
        children = [NSMutableArray new];
      }
      [children addObject:child];

    } else if ([[e name] isEqualToString:@"name"]) {
      if ([name length] > 0) {
        [name appendString:@"\n"];
      }
      [name appendString:[e stringValue]];

    } else if ([[e name] isEqualToString:@"appendix"]) {
      [name appendString:@"\n  "];
      [name appendString:[e stringValue]];

    } else {
      NSString* value = [[e stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
      if ([[e name] isEqualToString:@"style"]) {
        style = value;
      } else if ([[e name] isEqualToString:@"enable"]) {
        enableKey = value;
      } else if ([[e name] isEqualToString:@"keycode"]) {
        keyCodeKey = value;
      } else if ([[e name] isEqualToString:@"default"]) {
        defaultKeyCode = [value intValue];
      }
    }
  }

  MainConfigurationItem* item = [[MainConfigurationItem alloc] initWithName:name
                                                                      style:style
                                                                  enableKey:enableKey
                                                                 keyCodeKey:keyCodeKey
                                                             defaultKeyCode:defaultKeyCode];

  return [[MainConfigurationTree alloc] initWithItem:item children:children];
}

+ (KnownKeyCode*)parseKnownKeyCodeItem:(NSXMLElement*)element {
  NSString* name = nil;
  NSString* keyCode = nil;

  NSUInteger count = [element childCount];
  for (NSUInteger i = 0; i < count; ++i) {
    NSXMLElement* e = [XMLLoader castToNSXMLElement:[element childAtIndex:i]];
    if (!e) continue;

    NSString* value = [[e stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([[e name] isEqualToString:@"name"]) {
      name = value;
    } else if ([[e name] isEqualToString:@"keycode"]) {
      keyCode = value;
    }
  }

  return [[KnownKeyCode alloc] initWithName:name keyCode:keyCode];
}

@end
