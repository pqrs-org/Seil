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

#pragma mark - NSObject

- (id)replacementObjectForPortCoder:(NSPortCoder*)encoder {
  if ([encoder isBycopy]) return self;
  return [super replacementObjectForPortCoder:encoder];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder*)decoder {
  self = [super init];

  if (self) {
    self.id = [decoder decodeObjectForKey:@"id"];
    self.name = [decoder decodeObjectForKey:@"name"];
    self.style = [decoder decodeObjectForKey:@"style"];
    self.enableKey = [decoder decodeObjectForKey:@"enableKey"];
    self.keyCodeKey = [decoder decodeObjectForKey:@"keyCodeKey"];
    self.defaultKeyCode = [decoder decodeIntForKey:@"defaultKeyCode"];
  }

  return self;
}

- (void)encodeWithCoder:(NSCoder*)encoder {
  [encoder encodeObject:self.id forKey:@"id"];
  [encoder encodeObject:self.name forKey:@"name"];
  [encoder encodeObject:self.style forKey:@"style"];
  [encoder encodeObject:self.enableKey forKey:@"enableKey"];
  [encoder encodeObject:self.keyCodeKey forKey:@"keyCodeKey"];
  [encoder encodeInt:self.defaultKeyCode forKey:@"defaultKeyCode"];
}

- (id)copyWithZone:(NSZone*)zone {
  MainConfigurationItem* obj = [[[self class] allocWithZone:zone] init];
  if (obj) {
    obj.id = [self.id copyWithZone:zone];
    obj.name = [self.name copyWithZone:zone];
    obj.style = [self.style copyWithZone:zone];
    obj.enableKey = [self.enableKey copyWithZone:zone];
    obj.keyCodeKey = [self.keyCodeKey copyWithZone:zone];
    obj.defaultKeyCode = self.defaultKeyCode;
  }
  return obj;
}

@end

@interface MainConfigurationTree ()

@property(readwrite) MainConfigurationItem* node;
@property(copy, readwrite) NSArray* children;

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

#pragma mark - NSObject

- (id)replacementObjectForPortCoder:(NSPortCoder*)encoder {
  if ([encoder isBycopy]) return self;
  return [super replacementObjectForPortCoder:encoder];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder*)decoder {
  self = [super init];

  if (self) {
    self.node = [decoder decodeObjectForKey:@"node"];
    self.children = [decoder decodeObjectForKey:@"children"];
  }

  return self;
}

- (void)encodeWithCoder:(NSCoder*)encoder {
  [encoder encodeObject:self.node forKey:@"node"];
  [encoder encodeObject:self.children forKey:@"children"];
}

#pragma mark - NSCoping

- (id)copyWithZone:(NSZone*)zone {
  MainConfigurationTree* obj = [[[self class] allocWithZone:zone] init];
  if (obj) {
    obj.node = [self.node copyWithZone:zone];
    obj.children = [self.children copyWithZone:zone];
  }
  return obj;
}

@end
