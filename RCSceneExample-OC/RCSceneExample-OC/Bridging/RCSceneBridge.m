//
//  RCSceneBridge.m
//  RCSceneExample-OC
//
//  Created by shaoshuai on 2022/5/6.
//

#import <RongCloudOpenSource/RongIMKit.h>

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

+ (void)login:(NSString *)phone
      success:(void(^)(UserModel *))success
      failure:(void(^)(NSString *))failure {
    [RCVideoRoomService loginWithPhone:phone success:success failure:failure];
}

+ (void)fetchData:(void(^)(NSArray<RoomModel *> *))success
          failure:(void(^)(NSString *))failure {
    [RCVideoRoomService roomsWithSuccess:success failure:failure];
}

@end

@implementation UIViewController (Room)

- (void)show:(nullable RoomModel *)model {
    [RCSVRoom show:self room:model];
}

- (void)connectIM {
    if ([[RCIM sharedRCIM] getConnectionStatus] == ConnectionStatus_Connected) {
        return;
    }
    
    NSString *token = [[NSUserDefaults standardUserDefaults] oc_rongToken];
    if (token == nil) return [self performSegueWithIdentifier:@"Login" sender:nil];
    
    [[RCIM sharedRCIM] initWithAppKey:[AppConfigs appKey]];
    [[RCIM sharedRCIM] connectWithToken:token dbOpened:^(RCDBErrorCode code) {
        
    } success:^(NSString *userId) {
        
    } error:^(RCConnectErrorCode errorCode) {
        
    }];
}

@end
