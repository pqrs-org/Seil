#import "KnownKeyCode.h"

@interface KnownKeyCode ()

@property(copy, readwrite) NSString* name;
@property(readwrite) int keyCode;

@end

@implementation KnownKeyCode

- (instancetype)initWithName:(NSString*)name keyCode:(int)keyCode {
  self = [super init];

  if (self) {
    self.name = name;
    self.keyCode = keyCode;
  }

  return self;
}

@end
