//
//  UserModel.h
//  RCSceneExample-OC
//
//  Created by shaoshuai on 2022/5/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserModel : NSObject

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *portrait;
@property (nonatomic, copy) NSString *imToken;
@property (nonatomic, copy) NSString *authorization;

@property (nonatomic, assign) NSInteger type;

@end

NS_ASSUME_NONNULL_END
