//
//  RCSceneBridge.m
//  RCSceneExample-OC
//
//  Created by shaoshuai on 2022/5/6.
//

#import "RCSceneBridge.h"

#import "RCSceneExample_OC-Swift.h"

@implementation RCSceneBridge

+ (NSString *)IMToken {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"IMToken"];
}

+ (void)setIMToken:(NSString *)IMToken {
    [[NSUserDefaults standardUserDefaults] setObject:IMToken forKey:@"IMToken"];
}

+ (void)configApp {
    [AppConfigs config];
}

@end
