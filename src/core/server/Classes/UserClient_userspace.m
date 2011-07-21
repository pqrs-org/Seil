#import "UserClient_userspace.h"
#include "bridge.h"

static UserClient_userspace* global_instance = nil;

@implementation UserClient_userspace

@synthesize connected;

- (void) closeUserClient
{
  // ----------------------------------------
  // call BRIDGE_USERCLIENT_CLOSE
  if (service_ != IO_OBJECT_NULL && connect_ != IO_OBJECT_NULL) {
    // BRIDGE_USERCLIENT_CLOSE may be failed. (when kext is unloaded, etc.)
    // So we don't output a log message when it is failed.
    IOConnectCallScalarMethod(connect_, BRIDGE_USERCLIENT_CLOSE, NULL, 0, NULL, NULL);
  }

  // ----------------------------------------
  // release previous values.
  if (connect_ != IO_OBJECT_NULL) {
    IOServiceClose(connect_);
    connect_ = IO_OBJECT_NULL;
  }
  if (service_ != IO_OBJECT_NULL) {
    IOObjectRelease(service_);
    service_ = IO_OBJECT_NULL;
  }
}

- (void) openUserClient
{
  io_iterator_t iterator;

  kern_return_t kernResult = IOServiceGetMatchingServices(kIOMasterPortDefault, IOServiceMatching("org_pqrs_driver_PCKeyboardHack"), &iterator);
  if (kernResult != KERN_SUCCESS) {
    NSLog(@"[ERROR] IOServiceGetMatchingServices returned 0x%08x\n\n", kernResult);
    return;
  }

  for (;;) {
    io_service_t s = IOIteratorNext(iterator);
    if (s == IO_OBJECT_NULL) break;

    [self closeUserClient];

    // ----------------------------------------
    // setup service_
    service_ = s;
    kernResult = IOObjectRetain(service_);
    if (kernResult != KERN_SUCCESS) {
      NSLog(@"[ERROR] IOObjectRetain returned 0x%08x\n", kernResult);
      continue;
    }

    // ----------------------------------------
    // setup connect_
    kernResult = IOServiceOpen(service_, mach_task_self(), 0, &connect_);
    if (kernResult != KERN_SUCCESS) {
      NSLog(@"[ERROR] IOServiceOpen returned 0x%08x\n", kernResult);
      continue;
    }

    // ----------------------------------------
    // open
    kernResult = IOConnectCallScalarMethod(connect_, BRIDGE_USERCLIENT_OPEN, NULL, 0, NULL, NULL);
    if (kernResult != KERN_SUCCESS) {
      NSLog(@"[ERROR] BRIDGE_USERCLIENT_OPEN returned 0x%08x\n", kernResult);
      continue;
    }

    connected = YES;
  }

  IOObjectRelease(iterator);
}

- (id) init
{
  self = [super init];

  if (self) {
    service_ = IO_OBJECT_NULL;
    connect_ = IO_OBJECT_NULL;
    connected = NO;

    [self openUserClient];

    if (! connected) {
      [self closeUserClient];
    }
  }

  return self;
}

- (void) dealloc
{
  [self closeUserClient];

  [super dealloc];
}

// ======================================================================
+ (void) connect_to_kext
{
  @synchronized(self) {
    if (! global_instance) {
      global_instance = [self new];
    }
  }
}

+ (void) disconnect_from_kext
{
  @synchronized(self) {
    if (global_instance) {
      [global_instance release];
      global_instance = nil;
    }
  }
}

+ (void) refresh_connection
{
  [self disconnect_from_kext];
  [self connect_to_kext];
}

- (BOOL) do_synchronized_communication:(struct BridgeUserClientStruct*)bridgestruct
{
  if (connect_ == IO_OBJECT_NULL) return NO;
  if (! bridgestruct) return NO;

  uint64_t output = 0;
  uint32_t outputCnt = 1;
  kern_return_t kernResult = IOConnectCallMethod(connect_,
                                                 BRIDGE_USERCLIENT_SYNCHRONIZED_COMMUNICATION,
                                                 NULL, 0,                             // scalar input
                                                 bridgestruct, sizeof(*bridgestruct), // struct input
                                                 &output, &outputCnt,                 // scalar output
                                                 NULL, NULL);                         // struct output
  if (kernResult != KERN_SUCCESS) {
    NSLog(@"[ERROR] BRIDGE_USERCLIENT_SYNCHRONIZED_COMMUNICATION returned 0x%08x\n", kernResult);
    return NO;
  }
  if (output != BRIDGE_USERCLIENT_SYNCHRONIZED_COMMUNICATION_RETURN_SUCCESS) {
    NSLog(@"[ERROR] BRIDGE_USERCLIENT_SYNCHRONIZED_COMMUNICATION output is not SUCCESS (%d)\n", output);
    return NO;
  }

  return YES;
}

+ (BOOL) synchronized_communication:(struct BridgeUserClientStruct*)bridgestruct
{
  BOOL retval = NO;

  @synchronized(self) {
    if ([global_instance do_synchronized_communication:bridgestruct]) {
      retval = YES;
    }
  }

  return retval;
}

+ (BOOL) connected
{
  return [global_instance connected];
}

@end
