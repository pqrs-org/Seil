#import "Updater.h"

@implementation Updater

- (id) init
{
  self = [super init];

  if (self) {
    suupdater_ = [SUUpdater new];
  }

  return self;
}

- (void) dealloc
{
  [suupdater_ release];

  [super dealloc];
}

- (NSString*) getFeedURL
{
  NSInteger checkupdate = [preferencesManager_ checkForUpdatesMode];

  // ----------------------------------------
  // check nothing.
  if (checkupdate == 0) {
    return nil;
  }

  // ----------------------------------------
  // check beta & stable releases.

  // Once we check appcast.xml, SUFeedURL is stored in a user's preference file.
  // So that Sparkle gives priority to a preference over Info.plist,
  // we overwrite SUFeedURL here.
  if (checkupdate == 2) {
    return @"https://pqrs.org/macosx/keyremap4macbook/files/PCKeyboardHack-appcast-devel.xml";
  }

  return @"https://pqrs.org/macosx/keyremap4macbook/files/PCKeyboardHack-appcast.xml";
}

- (void) check:(BOOL)isBackground
{
  NSString* url = [self getFeedURL];
  if (! url) {
    NSLog(@"skip checkForUpdates");
    return;
  }
  [suupdater_ setFeedURL:[NSURL URLWithString:url]];

  NSLog(@"checkForUpdates %@", url);
  if (isBackground) {
    [suupdater_ checkForUpdatesInBackground];
  } else {
    [suupdater_ checkForUpdates:nil];
  }
}

- (IBAction) checkForUpdates:(id)sender
{
  [self check:NO];
}

- (IBAction) checkForUpdatesInBackground:(id)sender
{
  [self check:YES];
}


@end
