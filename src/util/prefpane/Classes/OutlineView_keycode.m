// -*- Mode: objc; Coding: utf-8; indent-tabs-mode: nil; -*-

#import "OutlineView_keycode.h"

@implementation org_pqrs_PCKeyboardHack_OutlineView_keycode

- (id) init
{
  self = [super init];

  if (self) {
    [self loadXML:@"/Library/org.pqrs/PCKeyboardHack/prefpane/known.xml"];
  }

  return self;
}

- (NSString*) getKeyName:(int)keycode
{
  NSString* keycodestring = [NSString stringWithFormat:@"%d", keycode];

  for (NSDictionary* dict in datasource_) {
    if ([keycodestring isEqualToString:[dict objectForKey:@"keycode"]]) {
      return [dict objectForKey:@"name"];
    }
  }
  return nil;
}

@end
