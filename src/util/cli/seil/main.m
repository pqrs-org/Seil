@import Cocoa;
#import "PreferencesModel.h"
#import "ServerClient.h"

@interface SeilCLI : NSObject

- (void)main;

@end

@implementation SeilCLI

- (void)output:(NSString*)string {
  NSFileHandle* fh = [NSFileHandle fileHandleWithStandardOutput];
  [fh writeData:[string dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)usage {
  [self output:@"Usage:\n"];
  [self output:@"  seil export\n"];
  [self output:@"  seil relaunch\n"];
  [self output:@"  seil set IDENTIFIER VALUE\n"];
  [self output:@"\n"];
  [self output:@"Example:\n"];
  [self output:@"  seil export\n"];
  [self output:@"  seil relaunch\n"];
  [self output:@"  seil set keycode_capslock 80\n"];
  [self output:@"\n"];
  [self output:@"(You can confirm all IDENTIFIER by export.)\n"];

  [[NSApplication sharedApplication] terminate:nil];
}

- (void) export:(ServerClient*)client {
  NSArray* arguments = [[NSProcessInfo processInfo] arguments];
  NSDictionary* dict = [client.proxy exportPreferences];

  [self output:@"#!/bin/sh\n\n"];
  [self output:[NSString stringWithFormat:@"cli=%@\n\n", arguments[0]]];

  for (NSString* key in [[dict allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]) {
    [self output:[NSString stringWithFormat:@"$cli set %@ %@\n", key, dict[key]]];
    [self output:@"/bin/echo -n .\n"];
  }
}

- (void)main {
  NSArray* arguments = [[NSProcessInfo processInfo] arguments];

  if ([arguments count] == 1) {
    [self usage];
  } else {
    @try {
      ServerClient* client = [ServerClient new];
      NSString* command = arguments[1];

      /*  */ if ([command isEqualToString:@"export"]) {
        [self export:client];
      } else if ([command isEqualToString:@"relaunch"]) {
        [client.proxy relaunch];
      } else if ([command isEqualToString:@"set"]) {
        if ([arguments count] != 4) {
          [self usage];
        }

        NSString* identifier = arguments[2];
        NSString* value = arguments[3];

        PreferencesModel* preferencesModel = [PreferencesModel new];
        [client.proxy loadPreferencesModel:preferencesModel];
        [preferencesModel setValue:[value intValue] forName:identifier];
        [client.proxy savePreferencesModel:preferencesModel processIdentifier:[NSProcessInfo processInfo].processIdentifier];
      }
    }
    @catch (NSException* exception) {
      NSLog(@"%@", exception);
    }
  }
}

@end

int main(int argc, const char* argv[]) {
  [[SeilCLI new] main];
  return 0;
}
