// -*- Mode: objc; Coding: utf-8; indent-tabs-mode: nil; -*-

#import <Cocoa/Cocoa.h>

@interface OutlineView : NSObject
{
  NSMutableArray* datasource_;
}

// @protected
- (void) loadXML:(NSString*)xmlpath;

@end
