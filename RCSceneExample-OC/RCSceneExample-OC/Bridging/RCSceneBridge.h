//
//  RCSceneBridge.h
//  RCSceneExample-OC
//
//  Created by shaoshuai on 2022/5/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCSceneBridge : NSObject

@property (nonatomic, copy, class) NSString *IMToken;

+ (void)configApp;

@end

NS_ASSUME_NONNULL_END
