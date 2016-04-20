#import "KnownKeyCode.h"

@interface KnownKeyCode ()

@property(copy, readwrite) NSString* name;
@property(copy, readwrite) NSString* keyCode;

@end

@implementation KnownKeyCode

- (instancetype)initWithName:(NSString*)name keyCode:(NSString*)keyCode {
  self = [super init];

  if (self) {
    self.name = name;
    self.keyCode = keyCode;
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
    self.name = [decoder decodeObjectForKey:@"name"];
    self.keyCode = [decoder decodeObjectForKey:@"keyCode"];
  }

  return self;
}

- (void)encodeWithCoder:(NSCoder*)encoder {
  [encoder encodeObject:self.name forKey:@"name"];
  [encoder encodeObject:self.keyCode forKey:@"keyCode"];
}

@end
