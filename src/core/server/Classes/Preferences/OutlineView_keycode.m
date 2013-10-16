// -*- Mode: objc; Coding: utf-8; indent-tabs-mode: nil; -*-

#import "OutlineView_keycode.h"

@implementation OutlineView_keycode

- (id) init
{
  self = [super init];

  if (self) {
    [self loadXML:[[NSBundle mainBundle] pathForResource:@"known" ofType:@"xml"]];
  }

  return self;
}

- (NSString*) getKeyName:(int)keycode
{
  NSString* keycodestring = [NSString stringWithFormat:@"%d", keycode];

  for (NSDictionary* dict in datasource_) {
    if ([keycodestring isEqualToString:dict[@"keycode"]]) {
      return dict[@"name"];
    }
  }
  return nil;
}

@end
