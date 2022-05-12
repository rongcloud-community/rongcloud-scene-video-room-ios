//
//  RoomUserModel.h
//  RCSceneExample-OC
//
//  Created by shaoshuai on 2022/5/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RoomUserModel : NSObject

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy, nullable) NSString *portrait;

@property (nonatomic, assign) NSInteger status;

@end

NS_ASSUME_NONNULL_END
