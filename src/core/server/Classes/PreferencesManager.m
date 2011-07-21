#import "PreferencesManager.h"
#import "PCKeyboardHackKeys.h"
#include <sys/time.h>

static PreferencesManager* global_instance = nil;

@implementation PreferencesManager

+ (PreferencesManager*) getInstance
{
  @synchronized(self) {
    if (! global_instance) {
      global_instance = [PreferencesManager new];
    }
  }
  return global_instance;
}

// ----------------------------------------
- (void) addToDefault:(NSXMLElement*)element
{
  for (NSXMLElement* e in [element elementsForName : @"identifier"]) {
    NSXMLNode* attr_default = [e attributeForName:@"default"];
    if (! attr_default) continue;

    [default_ setObject:[NSNumber numberWithInt:[[attr_default stringValue] intValue]] forKey:[e stringValue]];
  }

  for (NSXMLElement* e in [element elementsForName : @"list"]) {
    [self addToDefault:e];
  }
  for (NSXMLElement* e in [element elementsForName : @"item"]) {
    [self addToDefault:e];
  }
}

- (void) setDefault
{
  NSString* xmlpath = @"/Library/org.pqrs/PCKeyboardHack/prefpane/number.xml";
  NSURL* xmlurl = [NSURL fileURLWithPath:xmlpath];
  NSXMLDocument* xmldocument = [[[NSXMLDocument alloc] initWithContentsOfURL:xmlurl options:0 error:NULL] autorelease];
  if (xmldocument) {
    [self addToDefault:[xmldocument rootElement]];
  }
}

// ----------------------------------------
- (id) init
{
  self = [super init];

  if (self) {
    default_ = [NSMutableDictionary new];
    [self setDefault];

    // ------------------------------------------------------------
    serverconnection_ = [NSConnection new];
    [serverconnection_ setRootObject:self];
    [serverconnection_ registerName:kPCKeyboardHackConnectionName];

    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:kPCKeyboardHackServerLaunchedNotification object:kPCKeyboardHackNotificationKey];
  }

  return self;
}

- (void) dealloc
{
  [default_ release];
  [serverconnection_ release];

  [super dealloc];
}

// ----------------------------------------------------------------------
- (int) value:(NSString*)name
{
  NSString* identifier = @"sysctl";

  NSDictionary* dict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:identifier];
  if (dict) {
    NSNumber* number = [dict objectForKey:name];
    if (number) {
      return [number intValue];
    }
  }
  return [self defaultValue:name];
}

- (int) defaultValue:(NSString*)name
{
  NSNumber* number = [default_ objectForKey:name];
  if (number) {
    return [number intValue];
  } else {
    return 0;
  }
}

- (void) setValueForName:(int)newval forName:(NSString*)name
{
  NSString* identifier = @"sysctl";

  NSMutableDictionary* md = nil;

  NSDictionary* dict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:identifier];
  if (dict) {
    md = [NSMutableDictionary dictionaryWithDictionary:dict];
  } else {
    md = [[NSMutableDictionary new] autorelease];
  }
  if (! md) return;

  int defaultvalue = 0;
  NSNumber* defaultnumber = [default_ objectForKey:name];
  if (defaultnumber) {
    defaultvalue = [defaultnumber intValue];
  }

  if (newval == defaultvalue) {
    [md removeObjectForKey:name];
  } else {
    [md setObject:[NSNumber numberWithInt:newval] forKey:name];
  }

  [[NSUserDefaults standardUserDefaults] setObject:md forKey:identifier];
  //[[NSUserDefaults standardUserDefaults] synchronize];

  [[NSDistributedNotificationCenter defaultCenter] postNotificationName:kPCKeyboardHackPreferencesChangedNotification object:kPCKeyboardHackNotificationKey];
}

// ----------------------------------------------------------------------
- (NSString*) preferencepane_version
{
  return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

@end
