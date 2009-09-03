/* -*- Mode: objc; Coding: utf-8; indent-tabs-mode: nil; -*- */

#import "OutlineViewUtil.h"

@implementation BUNDLEPREFIX_OutlineViewUtil

+ (void) expandALL:(NSOutlineView *)outlineView
{
  [outlineView expandItem:nil expandChildren:YES];
}

+ (void) collapseALL:(NSOutlineView *)outlineView
{
  [outlineView collapseItem:nil collapseChildren:YES];
}

@end
