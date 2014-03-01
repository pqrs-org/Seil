@import Cocoa;
#import "PCKeyboardHackClient.h"

int
main(int argc, const char* argv[])
{
  PCKeyboardHackClient* client = [PCKeyboardHackClient new];
  [[client proxy] relaunch];

  return 0;
}
