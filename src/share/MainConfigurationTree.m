#import "MainConfigurationTree.h"

static NSInteger itemId_;
static dispatch_queue_t itemIdQueue_;

@interface MainConfigurationItem ()

@property(readwrite) NSNumber* id;
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

+ (void)initialize {
  itemId_ = 0;
  itemIdQueue_ = dispatch_queue_create("org.pqrs.Seil.MainConfigurationTree.itemIdQueue_", NULL);
}

- (instancetype)initWithName:(NSString*)name
                       style:(NSString*)style
                   enableKey:(NSString*)enableKey
                  keyCodeKey:(NSString*)keyCodeKey
              defaultKeyCode:(int)defaultKeyCode {
  self = [super init];

  if (self) {
    dispatch_sync(itemIdQueue_, ^{
      ++itemId_;
      self.id = @(itemId_);
    });

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
