//
//  HomeViewModel.m
//  RCSceneExample-OC
//
//  Created by shaoshuai on 2022/5/6.
//

#import "HomeViewModel.h"
#import "RCSceneBridge.h"

@implementation HomeViewModel

- (void)login:(NSString *)phone
      success:(void(^)(UserModel *))success
      failure:(void(^)(NSString *))failure {
    [RCSceneBridge login:phone success:success failure:failure];
}

- (void)fetchData:(void(^)(NSArray<RoomModel *> *))success
          failure:(void(^)(NSString *))failure {
    [RCSceneBridge fetchData:success failure:failure];
}

@end
