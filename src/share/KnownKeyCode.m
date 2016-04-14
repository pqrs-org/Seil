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

@end
