// -*- Mode: objc; Coding: utf-8; indent-tabs-mode: nil; -*-

#import "NotificationKeys.h"
#import "OutlineView_keycode.h"
#import "OutlineView_mixed.h"
#import "PreferencesManager.h"

@interface OutlineView_mixed () {
  NSMutableDictionary* textsHeightCache_;
  dispatch_queue_t textsHeightQueue_;
}
@end

@implementation OutlineView_mixed

+ (NSFont*)font {
  return [NSFont systemFontOfSize:[NSFont smallSystemFontSize]];
}

+ (CGFloat)textsHeight:(NSUInteger)lineCount {
  if (lineCount == 0) return 0.0f;

  NSString* line = @"gM\n";
  NSUInteger length = [line length] * lineCount - 1; // skip last '\n'
  NSString* texts = [[NSString string] stringByPaddingToLength:length withString:line startingAtIndex:0];
  NSDictionary* attributes = @{NSFontAttributeName : [OutlineView_mixed font]};
  NSSize size = [texts sizeWithAttributes:attributes];
  return size.height;
}

- (void)observer_PreferencesChanged:(NSNotification*)notification {
  dispatch_async(dispatch_get_main_queue(), ^{
    [outlineview_ setNeedsDisplay:YES];
  });
}

- (id)init {
  self = [super init];

  if (self) {
    textsHeightCache_ = [NSMutableDictionary new];
    textsHeightQueue_ = dispatch_queue_create("org.pqrs.Karabiner.OutlineView.textsHeightQueue_", NULL);

    [self loadXML:[[NSBundle mainBundle] pathForResource:@"checkbox" ofType:@"xml"]];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(observer_PreferencesChanged:)
                                                 name:kPreferencesChangedNotification
                                               object:nil];
  }

  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initialExpandCollapseTree {
  for (NSDictionary* dict in datasource_) {
    if ([dict[@"expand"] isEqualToString:@"true"]) {
      [outlineview_ expandItem:dict];
    } else {
      [outlineview_ collapseItem:dict];
    }
  }
}

// ------------------------------------------------------------
- (NSCell*)outlineView:(NSOutlineView*)outlineView dataCellForTableColumn:(NSTableColumn*)tableColumn item:(id)item {
  if (!tableColumn) return nil;

  NSString* identifier = [tableColumn identifier];

  if ([identifier isEqualToString:@"enable"]) {
    NSButtonCell* cell = [NSButtonCell new];
    [cell setFont:[OutlineView_mixed font]];
    [cell setButtonType:NSSwitchButton];
    [cell setTitle:item[@"name"]];

    {
      NSColor* backgroundColor = nil;
      NSString* style = item[@"style"];
      if ([style isEqualToString:@"caution"]) {
        backgroundColor = [NSColor greenColor];
      } else if ([style isEqualToString:@"important"]) {
        backgroundColor = [NSColor orangeColor];
      } else if ([style isEqualToString:@"slight"]) {
        backgroundColor = [NSColor lightGrayColor];
      }

      if (backgroundColor) {
        [cell setBackgroundColor:backgroundColor];
      }
    }

    if (!item[@"enable"]) {
      [cell setImagePosition:NSNoImage];
    }

    return cell;

  } else if ([identifier isEqualToString:@"default"]) {
    NSCell* cell = [NSCell new];
    [cell setFont:[OutlineView_mixed font]];
    [cell setEnabled:NO];

  } else if ([identifier isEqualToString:@"keycode"]) {
    if (!item[@"enable"]) {
      NSCell* cell = [NSCell new];
      [cell setFont:[OutlineView_mixed font]];
      return cell;

    } else {
      NSTextFieldCell* cell = [NSTextFieldCell new];
      [cell setFont:[OutlineView_mixed font]];
      [cell setEditable:YES];
      return cell;
    }
  }

  return nil;
}

- (id)outlineView:(NSOutlineView*)outlineView objectValueForTableColumn:(NSTableColumn*)tableColumn byItem:(id)item {
  NSString* identifier = [tableColumn identifier];

  if ([identifier isEqualToString:@"enable"]) {
    NSString* enable = item[@"enable"];
    if (!enable) {
      return nil;
    } else {
      return @([preferencesManager_ value:enable]);
    }

  } else if ([identifier isEqualToString:@"keycode"]) {
    NSString* keycode = item[@"keycode"];
    if (!keycode) return nil;

    return @([preferencesManager_ value:keycode]);

  } else if ([identifier isEqualToString:@"default"]) {
    NSString* keycode = item[@"keycode"];
    if (!keycode) return nil;

    int keycodevalue = [preferencesManager_ defaultValue:keycode];
    NSString* keycodename = [outlineView_keycode_ getKeyName:keycodevalue];

    return [NSString stringWithFormat:@"%d (%@)", keycodevalue, keycodename];
  }

  return nil;
}

- (void)outlineView:(NSOutlineView*)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn*)tableColumn byItem:(id)item {
  NSString* identifier = [tableColumn identifier];

  if ([identifier isEqualToString:@"enable"]) {
    NSString* enable = item[@"enable"];
    if (enable) {
      int value = [preferencesManager_ value:enable];
      value = !value;
      [preferencesManager_ setValueForName:value forName:enable];
    } else {
      // expand/collapse tree
      if ([outlineView isExpandable:item]) {
        if ([outlineView isItemExpanded:item]) {
          [outlineView collapseItem:item];
        } else {
          [outlineView expandItem:item];
        }
      }
    }

  } else if ([identifier isEqualToString:@"keycode"]) {
    NSString* keycode = item[@"keycode"];
    if (keycode) {
      [preferencesManager_ setValueForName:[object intValue] forName:keycode];
    }
  }
}

- (CGFloat)outlineView:(NSOutlineView*)outlineView heightOfRowByItem:(id)item {
  NSNumber* lineCount = item[@"height"];
  __block NSNumber* height = @([outlineView rowHeight]);

  if ([lineCount integerValue] > 1) {
    dispatch_sync(textsHeightQueue_, ^{
      if (textsHeightCache_[lineCount] == nil) {
        textsHeightCache_[lineCount] = @([OutlineView_mixed textsHeight:[lineCount unsignedIntegerValue]]);
      }
      // We add [outlineView rowHeight] as vertical margin.
      height = @([textsHeightCache_[lineCount] floatValue] + [outlineView rowHeight]);
    });
  }

  return [height floatValue];
}

@end
