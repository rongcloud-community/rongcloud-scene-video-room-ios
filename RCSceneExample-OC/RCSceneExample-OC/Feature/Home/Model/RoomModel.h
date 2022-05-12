//
//  RoomModel.h
//  RCSceneExample-OC
//
//  Created by shaoshuai on 2022/5/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class RoomUserModel;

@interface RoomModel : NSObject

@property (nonatomic, assign) NSInteger id;
@property (nonatomic, copy) NSString *roomId;
@property (nonatomic, copy) NSString *roomName;
@property (nonatomic, copy, nullable) NSString *themePictureUrl;
@property (nonatomic, copy, nullable) NSString *backgroundUrl;
@property (nonatomic, copy, nullable) NSString *password;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy, nullable) NSString *notice;

@property (nonatomic, assign) BOOL isPrivate;
@property (nonatomic, assign) BOOL stop;
@property (nonatomic, assign) NSInteger userTotal;
@property (nonatomic, assign) NSInteger roomType;

@property (nonatomic, strong, nullable) RoomUserModel *createUser;

@end

NS_ASSUME_NONNULL_END
