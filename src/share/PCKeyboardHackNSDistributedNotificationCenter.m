#import "PCKeyboardHackNSDistributedNotificationCenter.h"
#import "PCKeyboardHackKeys.h"

@implementation org_pqrs_PCKeyboardHack_NSDistributedNotificationCenter

+ (void) addObserver:(id)notificationObserver selector:(SEL)notificationSelector name:(NSString*)notificationName
{
  [org_pqrs_PCKeyboardHack_NSDistributedNotificationCenter addObserver:notificationObserver
                                                              selector:notificationSelector
                                                                  name:notificationName
                                                                object:kPCKeyboardHackNotificationKey];
}

+ (void) addObserver:(id)notificationObserver selector:(SEL)notificationSelector name:(NSString*)notificationName object:(NSString*)notificationSender
{
  // In Mac OS X 10.7, NSDistributedNotificationCenter is suspended after calling [NSAlert runModal].
  // So, we need to set suspendedDeliveryBehavior to NSNotificationSuspensionBehaviorDeliverImmediately.

  [[NSDistributedNotificationCenter defaultCenter] addObserver:notificationObserver
                                                      selector:notificationSelector
                                                          name:notificationName
                                                        object:notificationSender
                                            suspensionBehavior:NSNotificationSuspensionBehaviorDeliverImmediately];
}

+ (void) removeObserver:(id)notificationObserver name:(NSString*)notificationName
{
  [[NSDistributedNotificationCenter defaultCenter] removeObserver:notificationObserver
                                                             name:notificationName
                                                           object:kPCKeyboardHackNotificationKey];
}

+ (void) postNotificationName:(NSString*)notificationName userInfo:(NSDictionary*)userInfo
{
  // In Mac OS X 10.7, NSDistributedNotificationCenter is suspended after calling [NSAlert runModal].
  // So, we need to call postNotificationName with deliverImmediately:YES.

  [[NSDistributedNotificationCenter defaultCenter] postNotificationName:notificationName
                                                                 object:kPCKeyboardHackNotificationKey
                                                               userInfo:userInfo
                                                     deliverImmediately:YES];
}

@end
