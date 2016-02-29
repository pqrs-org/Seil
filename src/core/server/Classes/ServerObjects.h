/* -*- Mode: objc; Coding: utf-8; indent-tabs-mode: nil; -*- */

@import Cocoa;

@class ClientForKernelspace;
@class PreferencesManager;
@class Updater;

@interface ServerObjects : NSObject

@property(weak) IBOutlet ClientForKernelspace* clientForKernelspace;
@property(weak) IBOutlet PreferencesManager* preferencesManager;
@property(weak) IBOutlet Updater* updater;

@end
