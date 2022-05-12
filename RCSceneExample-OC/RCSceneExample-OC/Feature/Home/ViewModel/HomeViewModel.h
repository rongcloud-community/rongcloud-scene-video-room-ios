//
//  HomeViewModel.h
//  RCSceneExample-OC
//
//  Created by shaoshuai on 2022/5/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class RoomModel, UserModel;

@interface HomeViewModel : NSObject

- (void)login:(NSString *)phone
      success:(void(^)(UserModel *))success
      failure:(void(^)(NSString *))failure;

- (void)fetchData:(void(^)(NSArray<RoomModel *> *))success
          failure:(void(^)(NSString *))failure;

@end

NS_ASSUME_NONNULL_END
