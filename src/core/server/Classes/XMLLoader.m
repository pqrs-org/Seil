#import "XMLLoader.h"

static NSInteger itemId_;
static dispatch_queue_t itemIdQueue_;

@implementation XMLLoader

+ (void)initialize {
  itemId_ = 0;
  itemIdQueue_ = dispatch_queue_create("org.pqrs.Seil.XMLCompiler.xmlCompilerItemIdQueue_", NULL);
}

+ (NSXMLElement*)castToNSXMLElement:(NSXMLNode*)node {
  if ([node kind] != NSXMLElementKind) return nil;
  return (NSXMLElement*)(node);
}

+ (NSMutableDictionary*)parseItemTag:(NSXMLElement*)item {
  NSMutableDictionary* dict = [NSMutableDictionary new];
  NSMutableString* name = [NSMutableString new];

  NSUInteger count = [item childCount];
  for (NSUInteger i = 0; i < count; ++i) {
    NSXMLElement* e = [XMLLoader castToNSXMLElement:[item childAtIndex:i]];
    if (!e) continue;

    if ([[e name] isEqualToString:@"item"]) {
      NSMutableDictionary* child = [XMLLoader parseItemTag:e];
      NSMutableArray* children = dict[@"children"];
      if (!children) {
        children = [NSMutableArray new];
      }
      [children addObject:child];
      dict[@"children"] = children;

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
      dict[[e name]] = value;
    }
  }

  dict[@"name"] = name;

  dispatch_sync(itemIdQueue_, ^{
    ++itemId_;
    dict[@"id"] = @(itemId_);
  });

  return dict;
}

+ (NSArray*)load:(NSString*)xmlpath {
  NSMutableArray* result = [NSMutableArray new];

  NSURL* url = [NSURL fileURLWithPath:xmlpath];
  NSError* error = nil;
  NSXMLDocument* xmldocument = [[NSXMLDocument alloc] initWithContentsOfURL:url options:0 error:&error];
  if (!xmldocument) {
    NSLog(@"XML error %@", [error localizedDescription]);
    return result;
  }

  NSXMLElement* root = [xmldocument rootElement];
  NSUInteger itemcount = [root childCount];
  for (NSUInteger i = 0; i < itemcount; ++i) {
    NSXMLElement* item = [XMLLoader castToNSXMLElement:[root childAtIndex:i]];
    if (!item) continue;

    [result addObject:[XMLLoader parseItemTag:item]];
  }

  return result;
}

@end
