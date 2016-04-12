/* -*- Mode: objc; Coding: utf-8; indent-tabs-mode: nil; -*- */

@import Cocoa;

@class ClientForKernelspace;
@class PreferencesManager;
@class PreferencesModel;
@class ServerForUserspace;
@class Updater;

@interface ServerObjects : NSObject

@property(weak) IBOutlet ClientForKernelspace* clientForKernelspace;
@property(weak) IBOutlet PreferencesManager* preferencesManager;
@property(weak) IBOutlet PreferencesModel* preferencesModel;
@property(weak) IBOutlet ServerForUserspace* serverForUserspace;
@property(weak) IBOutlet Updater* updater;

@end
