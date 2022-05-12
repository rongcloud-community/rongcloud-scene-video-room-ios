//
//  HomeViewModel.m
//  RCSceneExample-OC
//
//  Created by shaoshuai on 2022/5/6.
//

#import "HomeViewModel.h"

#import "RCSceneExample_OC-Swift.h"

@interface HomeViewModel ()

@property (nonatomic, strong) RCVideoRoomService *service;

@end

@implementation HomeViewModel

- (RCVideoRoomService *)service {
    if (_service) return _service;
    _service = [[RCVideoRoomService alloc] init];
    return _service;
}

- (void)login:(NSString *)phone
      success:(void(^)(UserModel *))success
      failure:(void(^)(NSString *))failure {
    [self.service loginWithPhone:phone success:success failure:failure];
}

- (void)fetchData:(void(^)(NSArray<RoomModel *> *))success
          failure:(void(^)(NSString *))failure {
    [self.service roomsWithSuccess:success failure:failure];
}

@end
