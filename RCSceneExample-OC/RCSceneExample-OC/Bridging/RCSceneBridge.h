//
//  RCSceneBridge.h
//  RCSceneExample-OC
//
//  Created by shaoshuai on 2022/5/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class UserModel, RoomModel;

@interface RCSceneBridge : NSObject

@property (nonatomic, copy, class) NSString *IMToken;

+ (void)configApp;

+ (void)login:(NSString *)phone
      success:(void(^)(UserModel *))success
      failure:(void(^)(NSString *))failure;

+ (void)fetchData:(void(^)(NSArray<RoomModel *> *))success
          failure:(void(^)(NSString *))failure;

@end

@interface UIViewController (Room)

- (void)connectIM;

- (void)show:(nullable RoomModel *)model;

@end

NS_ASSUME_NONNULL_END
