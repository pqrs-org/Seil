#import "MainConfigurationTree.h"

@interface MainConfigurationItem ()

@property(copy, readwrite) NSString* name;
@property(copy, readwrite) NSString* style;
@property(copy, readwrite) NSString* enableKey;
@property(copy, readwrite) NSString* keyCodeKey;
@property(readwrite) int defaultKeyCode;

@end

@interface MainConfigurationTree ()

@property(readwrite) MainConfigurationItem* node;
@property(copy, readwrite) NSArray* children;

@end

@implementation MainConfigurationItem

- (instancetype)initWithName:(NSString*)name
                       style:(NSString*)style
                   enableKey:(NSString*)enableKey
                  keyCodeKey:(NSString*)keyCodeKey
              defaultKeyCode:(int)defaultKeyCode {
  self = [super init];

  if (self) {
    self.name = name;
    self.style = style;
    self.enableKey = enableKey;
    self.keyCodeKey = keyCodeKey;
    self.defaultKeyCode = defaultKeyCode;
  }

  return self;
}

@end

@implementation MainConfigurationTree

- (instancetype)initWithItem:(MainConfigurationItem*)node
                    children:(NSArray*)children {
  self = [super init];

  if (self) {
    self.node = node;
    self.children = children;
  }

  return self;
}

@end
