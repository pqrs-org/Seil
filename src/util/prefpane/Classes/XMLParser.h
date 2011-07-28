// -*- Mode: objc; Coding: utf-8; indent-tabs-mode: nil; -*-
#import <Cocoa/Cocoa.h>

@interface org_pqrs_PCKeyboardHack_XMLParser : NSObject
{
  NSMutableArray* datasource_;
}

// @protected
- (void) loadXML:(NSString*)xmlpath;

@end
