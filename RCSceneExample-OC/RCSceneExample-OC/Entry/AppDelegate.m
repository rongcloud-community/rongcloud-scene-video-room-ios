//
//  AppDelegate.m
//  RCSceneExample-OC
//
//  Created by shaoshuai on 2022/5/6.
//

#import "AppDelegate.h"
#import "RCSceneBridge.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [RCSceneBridge configApp];
    return YES;
}

@end
