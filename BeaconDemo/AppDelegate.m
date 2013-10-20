//
//  AppDelegate.m
//  BeaconDemo
//
//  Created by Oleksandr Skrypnyk on 10/19/13.
//  Copyright (c) 2013 Unteleported. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

+ (BOOL)IOS7 {
  static BOOL _IOS7;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _IOS7 = floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1;
  });
  return _IOS7;
}

+ (BOOL)iPhone5 {
  static BOOL _iPhone5;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _iPhone5 = [UIScreen mainScreen].applicationFrame.size.height >= 548;
  });
  return _iPhone5;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
  [[[UIAlertView alloc] initWithTitle:@"BeaconDemo" message:notification.alertBody delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
}

@end
